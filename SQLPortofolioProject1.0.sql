select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract Covid in Togo
select location, date, total_cases, cast(total_deaths as int) as Total_deaths,(cast(total_deaths as int)/total_cases)*100 as DeathPercentage 
from PortofolioProject..CovidDeaths
where location = 'france'
order by date



--Looking at total cases vs population
--Shows what percentage of population got Covid
select location, date, total_cases, population,(total_cases/population)*100 as PopulationPercentage 
from PortofolioProject..CovidDeaths
where location = 'Togo'
order by 1,2


--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PopulationPercentage 
from PortofolioProject..CovidDeaths
group by location, population
order by PopulationPercentage desc


--Showing countries in Africa with highest death count per population
select location, max(cast(total_deaths as int)) as Highest_Death_Count 
from PortofolioProject..CovidDeaths
where continent is not null and continent = 'africa'
group by location
order by Highest_Death_Count desc




--Global Numbers
Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2



--Joining the both tables
select * 
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


	--Use CTE

with PopvsVac(continent, location, date, population, ew_vaccinations, Rolling_people_vaccinated)
as

(
--Looking at Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as Rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rolling_people_vaccinated/population)*100
from PopvsVac




--TEMP Table

drop table if exists #Percent_population_vaccinated

create table #Percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
Rolling_people_vaccinated numeric
)


Insert into #Percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as Rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * , (Rolling_people_vaccinated/population)*100
from #Percent_population_vaccinated



--Creating view to store data for later visualizations
drop view if exists PercentPopulationVaccinated

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVaccinated