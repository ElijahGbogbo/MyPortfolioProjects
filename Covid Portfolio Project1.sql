/*

Covid 19 Data Exploration 

Skills used: Aggregate Functions, Joins, CTE's, Temp Tables, Windows Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3, 4



-- COVID DEATHS TABLE
-- This gives the data that we will by analyzing

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Order by 1, 2


-- ANALYSIS BASED ON COUNTRIES
-- This shows the percentage of people that were infected by covid and died in Nigeria

Select location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/cast(total_cases as float)) * 100 as PercentageOfDeathsPerCase
From PortfolioProject.dbo.CovidDeaths
Where location = 'Nigeria' and continent is not null
Order by 1, 2



-- This shows the percentage of people that were infected by covid in all Countries

Select location, date, total_cases, population, 
(cast(total_cases as float)/population) * 100 as PercentageOfCovidCasesPerPopulation
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--Where location = 'Nigeria'
Order by 1, 2



-- This shows countries with high infection counts per population

Select location, population, MAX(cast(total_cases as int)) as MaximumInfectionCount, 
(MAX(cast(total_cases as float)/population)) * 100 as PercentageOfPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location, population
Order by PercentageOfPopulationInfected desc



-- This shows countries with high death counts

Select location, MAX(cast(total_deaths as int)) as MaximumDeathCount
From PortfolioProject.dbo.CovidDeaths
 where continent is not null
Group by location
Order by MaximumDeathCount desc



-- ANALYSIS BASED ON CONTINENT
-- This shows continents with high death counts

Select continent, MAX(cast(total_deaths as int)) as MaximumDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
Group by continent
Order by MaximumDeathCount desc



-- ANALYSIS BASED ON THE WHOLE WORLD
-- Global death percentage-> This shows the percentage of people that were infected by Covid and died in the world

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
Case
	when SUM(new_cases) = 0 and SUM(new_deaths) = 0 then 0
	when SUM(new_cases) is null and SUM(new_deaths) is null then null
	Else (SUM(new_deaths)/SUM(new_cases))*100
End as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
Order by 1, 2



-- COMBINED COVID DEATH AND VACCINATION TABLES
Select *
From PortfolioProject..CovidDeaths as death
Join PortfolioProject..CovidVaccinations as vacc
	On death.location = vacc.location
	and death.date = vacc.date



-- This shows the total population, total vaccinations and rolling sum of vaccinations by Countries in the world

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatedPersons
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


-- Using CTE to create an additional column that gives the calculation of the percentage of a country's poppulation that were vaccinated
-- on a daily basis

With PercentagePopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedPersons)
As
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatedPersons
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)

Select *, (RollingVaccinatedPersons/Population)*100 as PercentageOfPopulationVaccinated
From PercentagePopulationVaccinated



-- Using Temp Tables to create an additional column that gives the calculation of the percentage of a country's poppulation that were 
-- vaccinated on a daily basis

Drop Table #Temp_PercentagePopulationVaccinated
Create Table #Temp_PercentagePopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population int, 
New_Vaccinations int, 
RollingVaccinatedPersons float)

Insert into #Temp_PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatedPersons
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

Select *, (RollingVaccinatedPersons/Population)*100 as PercentageOfPopulationVaccinated
From #Temp_PercentagePopulationVaccinated
Order by 2,3





-- Creating view to store data for later visualizations

Create View PercentagePopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatedPersons
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentagePopulationVaccinated











