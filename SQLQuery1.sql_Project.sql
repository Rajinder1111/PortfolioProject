Select *
From project..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From project..CovidVaccinations$
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From project..CovidDeaths$
order by 1,2

--Looking at Total cases VS Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From project..CovidDeaths$
where location like '%India%'
order by 1,2


--Looking at thr Total cases VS Population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From project..CovidDeaths$
--where location like '%India%'
order by 1,2


--Looking at Countries with highest Infection rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
From project..CovidDeaths$
--where location like '%India%'
Group by Location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From project..CovidDeaths$
where continent is not null
Group by Location
Order by TotalDeathCount desc

--Lets break things down by continent

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From project..CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Showing the continents  with highest death per population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From project..CovidDeaths$
where location is like '%India%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From project..CovidDeaths$
--where location is like '%India%'
where continent is not null
Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From project..CovidDeaths$ dea
Join project..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From project..CovidDeaths$ dea
Join project..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  From PopvsVac



  --TEMP TABLE

  DROP Table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccination numeric,
  RollingPeopleVaccinated numeric
  )

  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From project..CovidDeaths$ dea
Join project..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  Select *, (RollingPeopleVaccinated/Population)*100
  From #PercentPopulationVaccinated
 


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From project..CovidDeaths$ dea
Join project..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  select *
  from PercentPopulationVaccinated