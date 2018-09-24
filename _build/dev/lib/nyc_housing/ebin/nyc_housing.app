{application,nyc_housing,
             [{applications,[kernel,stdlib,elixir,logger,recase,poison,timex,
                             httpoison,postgrex,ecto,quantum]},
              {description,"nyc_housing"},
              {modules,['Elixir.NycHousing','Elixir.NycHousing.Application',
                        'Elixir.NycHousing.Lottery',
                        'Elixir.NycHousing.Lottery.Api',
                        'Elixir.NycHousing.Lottery.Api.Lookup',
                        'Elixir.NycHousing.Lottery.Api.Project',
                        'Elixir.NycHousing.Lottery.Neighborhood',
                        'Elixir.NycHousing.Lottery.Project',
                        'Elixir.NycHousing.Lottery.Store',
                        'Elixir.NycHousing.Repo',
                        'Elixir.NycHousing.Scheduler']},
              {registered,[]},
              {vsn,"0.1.0"},
              {mod,{'Elixir.NycHousing.Application',[]}}]}.