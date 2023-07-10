select *
from SQLportfolioproject..coviddeaths$
order by 3,4

--select *
--from SQLportfolioproject..covidvaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from SQLportfolioproject..coviddeaths$
order by 1,2

--ALTER COLUMN DATATYPES TO ENABLE CALCULATIONS

ALTER TABLE DBO.COVIDDEATHS$
ALTER COLUMN TOTAL_DEATHS FLOAT

ALTER TABLE DBO.COVIDDEATHS$
ALTER COLUMN TOTAL_CASES FLOAT

--TOTAL DEATHS VS TOTAL CASES; mortality rate upon contracting COVID.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATHPERCENTAGE
from SQLportfolioproject..coviddeaths$
where location like 'united kingdom'
order by 1,2

-- Total CASES VS POPULATION; percentage of population that contracted Covid

select location, date, population, total_cases, (total_cases/population)*100 AS totalcasesvspopulation
from SQLportfolioproject..coviddeaths$
where location like 'united kingdom'
order by 1,2

--countries with Highest Infection Rate against population

select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 AS percentpopulationinfected
from SQLportfolioproject..coviddeaths$
--where location like 'united kingdom'
group by location, population
order by percentpopulationinfected desc

--countries with highest deathcount/population
select location, MAX(total_deaths) as TotalDeathCount
from SQLportfolioproject..coviddeaths$
--where location like 'united kingdom'
where continent is not null
group by location
order by TotalDeathCount desc

--continent with the highest death count

select continent, MAX(total_deaths) as TotalDeathCount
from SQLportfolioproject..coviddeaths$
--where location like 'united kingdom'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DEATHPERCENTAGE
from SQLportfolioproject..coviddeaths$
--where location like 'united kingdom'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as rollingpeoplevaccinated
from SQLportfolioproject..coviddeaths$ dea
join SQLportfolioproject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 5

-- USE CTE

with PopulationvsVaccianation (Continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as rollingpeoplevaccinated
from SQLportfolioproject..coviddeaths$ dea
join SQLportfolioproject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopulationvsVaccianation

-- TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
rollingpeoplevaccinated bigint
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as rollingpeoplevaccinated
from SQLportfolioproject..coviddeaths$ dea
join SQLportfolioproject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view for later visualisations

Create view rollingpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as rollingpeoplevaccinated
from SQLportfolioproject..coviddeaths$ dea
join SQLportfolioproject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated

select *
from rollingpeoplevaccinated