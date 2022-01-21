
Select *
From Portfolioproject..CovidDeaths
order by 3,4


--Select *
--From Portfolioproject..CovidVaccinations
--order by 3,4

-- The data I will be using 

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
order by 1,2
-- likelihood of dying if you are infected in united states
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs Population 
-- Shows what percentage of population got covid 
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage 
From Portfolioproject..CovidDeaths
order by 1,2

--Countries with highest infection rate compared to population 

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPopulationPercentage 
From Portfolioproject..CovidDeaths
group by population, location
order by InfectedPopulationPercentage desc

--Countries with the highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
From Portfolioproject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Highest death count by continent 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount 
From Portfolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global covid numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

-- joining two tables
Select *
From Portfolioproject..CovidDeaths cd
Join Portfolioproject..CovidVaccinations cv
   on cd.location = cv.location
   and cd.date = cv.date

--Total population vs vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
From Portfolioproject..CovidDeaths cd
Join Portfolioproject..CovidVaccinations cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null 
order by 2,3



Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,
  cd.date) as RollingPeopleVaccinated 
From Portfolioproject..CovidDeaths cd
Join Portfolioproject..CovidVaccinations cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null 
order by 2,3




--CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,
  cd.date) as RollingPeopleVaccinated 
From Portfolioproject..CovidDeaths cd
Join Portfolioproject..CovidVaccinations cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER(Partition by cd.Location Order by cd.location,
cd.Date) as RollingPeopleVaccinated
From Portfolioproject..CovidDeaths cd
Join Portfolioproject..CovidVaccinations cv
     On cd.location = cv.location
	 and cd.date = cv.date

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 


-- data for visualization

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER(Partition by cd.Location Order by cd.location,
cd.Date) as RollingPeopleVaccinated
From Portfolioproject..CovidDeaths cd
Join Portfolioproject..CovidVaccinations cv
     On cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null

--viewing the table I created
Select *
From PercentPopulationVaccinated


