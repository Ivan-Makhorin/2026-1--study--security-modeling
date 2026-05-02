using DrWatson
@quickactivate "project"
using Graphs, Plots, Random

include(srcdir("attack_graph.jl"))

n = 20
edge_prob = 0.15
Random.seed!(123)
g = build_attack_graph(n, edge_prob, Dict(), [(2,5), (8,12)])

initial_infected = [1]
transmission_prob = 0.7   # вероятность передачи заражения по ребру
max_steps = 20

infected = falses(n)
infected[initial_infected] .= true
history = [copy(infected)]

for step = 1:max_steps
    new_infected = copy(infected)
    for v in 1:n
        if !infected[v]
            for u in inneighbors(g, v)   # проверяем всех входящих соседей
                if infected[u] && rand() < transmission_prob
                    new_infected[v] = true
                    break
                end
            end
        end
    end
    if new_infected == infected
        break
    end
    infected = new_infected
    push!(history, copy(infected))
end

steps = length(history)
infected_count = [sum(h) for h in history]
plot(0:steps-1, infected_count, marker=:circle,
     xlabel="Шаг", ylabel="Число заражённых узлов",
     title="Распространение атаки", legend=false)
savefig(plotsdir("agent_spread.png"))
println("График сохранён в plots/agent_spread.png")
println("Всего заражено узлов: ", sum(infected))
