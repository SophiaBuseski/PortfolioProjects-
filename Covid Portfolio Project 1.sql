/* 
Covid 19 Data Exploration 

Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types 
 
*/ 

Select * 
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null
Order By 3,4

Select * 
From PortfolioProjects.dbo.CovidVaccinations
Where continent is not null 
Order By 3,4

-- SELECTING DATA TO USE

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null
Order By 1,2

-- TOTAL CASES VS TOTAL DEATHS
-- (shows the likelihood of dying if you get covid in your country) 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercetage
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null and location like '%state%'
Order By 1,2

-- TOTAL CASES VS POPULATION 
-- (shows what percentage of population has gotten covid)

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Order By 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Group By location, population
Order By PercentPopulationInfected desc

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location
Order By TotalDeathCount desc

-- CONTINENT SPECIFIC -- 

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc

-- GLOBAL NUMBERS 

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
Order By 1,2


-- TOTAL POPULATIONS VS VACCINATIONS
-- (shows percentage of population that recieved at least one vaccine) 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProjects.dbo.CovidDeaths dea
Join PortfolioProjects.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
--Order By 2,3

-- CTE FOR ABOVE CALCULATION

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location,dea.date)
	as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 
From PortfolioProjects.dbo.CovidDeaths dea
Join PortfolioProjects.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
--Order By 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE FOR ABOVE CALCULATION

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location,dea.date)
	as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 
From PortfolioProjects.dbo.CovidDeaths dea
Join PortfolioProjects.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- CREATING VIEW FOR VISUAL 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location,dea.date)
	as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 
From PortfolioProjects.dbo.CovidDeaths dea
Join PortfolioProjects.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
