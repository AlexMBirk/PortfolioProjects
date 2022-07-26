select * 
from portfolioproject..coviddeaths
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood od dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpertentage
from portfolioproject..coviddeaths
order by 1,2

--looking at Total Cases vs Population
select location,date,total_cases,population, (total_cases/population)*100 as CasesPerPop
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2

--countries with highest infection rate to population
select continent, location, population,max(total_cases) as highestInfCount, max((total_cases/population))*100 as percentPopInfected
from portfolioproject..coviddeaths
where continent is not null
group by location,population,continent
order by percentPopInfected desc

--showing countries with highest death count per Pop
select continent, location, max(cast(total_deaths as int)) as TotalDeathCount, max(population) as population
from portfolioproject..coviddeaths
where continent is not null
group by continent,location
order by TotalDeathCount desc
--breaking down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount, max(population) as population
from portfolioproject..coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc
-- North america doesnt seem to be including canada, maybe use location

-- grouping by both location and continent will make it possible to drill down when making visuals
select location,continent, max(cast(total_deaths as int)) as TotalDeathCount, max(population) as population
from portfolioproject..coviddeaths
where continent is not null
group by location,continent
order by TotalDeathCount desc

--global numbers
select sum(total_cases) as totalCases, sum(cast(new_deaths as int)) as deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathsPercentage
from portfolioproject..coviddeaths
where continent is not null
--group by date
order by 1,2

--create a cte
with PopsVac  (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(	
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations	
	, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvacinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)

select * , (RollingPeopleVaccinated/population)*100 as VaccPerPop
from PopsVac

--could also be done with a temp table
drop TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations	
	, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvacinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	select *, (RollingPeopleVaccinated/population)*100 as VacPerPopPercent
	from #PercentPopulationVaccinated


	--creating view to store date for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvacinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from #PercentPopulationVaccinated