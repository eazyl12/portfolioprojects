Select *
From portfolioproject..coviddeath
Where continent is not Null
Order by 3,4

--Select *
--From portfolioproject..Covidvacination
--Order by 3,4

-- select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..coviddeath
Where continent is not Null
Order by 1,2


--looking at Total cases vs Total Deaths
-- shows the likelihood of dying if you contract covid19

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..coviddeath
Where location like '%states%'
Where continent is not Null
Order by 1,2

-- Looking at The Total Cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From portfolioproject..coviddeath
--Where location like '%states%'
Where continent is not Null
Order by 1,2


-- Looking at countries with highest infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
From portfolioproject..coviddeath
--Where location like '%states%'
Group by location, population
Where continent is not Null
Order by PercentagePopulationInfected desc

-- Showing Countries With Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From portfolioproject..coviddeath
--Where location like '%states%'
Where continent is not Null
Group by location
Order by TotalDeathCount desc

-- Lets break things down by Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..coviddeath
--Where location like '%states%'
Where continent is not Null
Group by location
Order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..coviddeath
--Where location like '%states%'
Where continent is not Null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolioproject..coviddeath
--Where location like '%states%'
Where continent is not Null
--Group by date
Order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..coviddeath dea
Join portfolioproject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is Not Null
Order by 2,3




--USE CTE

with popvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..coviddeath dea
Join portfolioproject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is Not Null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
from popvsVac




TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..coviddeath dea
Join portfolioproject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is Not Null
--Order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..coviddeath dea
Join portfolioproject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is Not Null
--Order by 2,3

Select *
From PercentPopulationVaccinated
