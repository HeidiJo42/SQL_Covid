
Select *
From PortfolioProject..['Covid Deaths$']
order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations 09-22-21$']
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 1,2


-- looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where continent is not null and location like '%states%'
order by 1,2

-- looking at total cases vs population for States

Select Location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
From PortfolioProject..['Covid Deaths$']
Where continent is not null and location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases), MAX((total_cases/population))*100 as HighestInfection
From PortfolioProject..['Covid Deaths$']
-- where location like '%New%'
Where continent is not null
Group by Location, population
order by HighestInfection desc


-- showing countries with the highest death count per population
-- Trouble shooting MAX() function: need to Cast as an int

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Trouble shooting location grouping
--  continent is pulling under country:
-- fix: original data location = 'Africa' and continent = 'NULL'
-- Added to previous queries with 'Location' 

--Select *
-- From PortfolioProject..['Covid Deaths$']
-- order by 3,4

-- More checking of the data for 'location' and 'continent'
-- this is correct for pulling totals per continent totals


Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
Where continent is null
Group by location
order by TotalDeathCount desc

-- More checking of the data for 'location' and 'continent'
-- per country correct

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
Where continent is not null
Group by location
order by TotalDeathCount desc





-- GLOBAL NUMBERS total cases, total deaths, and death percent
-- need to cast int for SUM() function

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- new cases per date worldwide

Select date, SUM(new_cases) -- as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
where continent is not null 
Group By date
order by 1,2






-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Adding in vaccinations data through Join with abbriviation
-- Testing Join for accuracy

Select *
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Next:  add column for % of total population vaccinated 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

  
-- Using Temp Table to perfom calculation on partition by in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Clean Until here:
-- Temp Table 2

Drop table if exists #PercentPopVacc
Create Table #PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollPeopVacc
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopVacc


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Vaccinations 09-22-21$'] vac
Join PortfolioProject..['Covid Deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated

