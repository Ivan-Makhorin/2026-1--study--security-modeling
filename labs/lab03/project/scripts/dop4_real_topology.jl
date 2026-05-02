# # Анализ реальной топологии сети
#
# Используется граф Facebook (из SNAPDatasets), преобразуется в ориентированный
# путём дублирования рёбер в обоих направлениях.
# Затем применяются инструменты лабораторной работы (метрики центральности, визуализация).
# Поиск всех путей заменён на поиск кратчайшего пути из-за большого размера графа.

# %% Инициализация
using DrWatson
@quickactivate "project"
using Graphs, Plots, GraphRecipes, SNAPDatasets

include(srcdir("attack_graph.jl"))

# %% Загрузка графа Facebook и преобразование в ориентированный
g_undirected = loadsnap(:facebook_combined)
g_directed = SimpleDiGraph(nv(g_undirected))
for e in edges(g_undirected)
    add_edge!(g_directed, src(e), dst(e))
    add_edge!(g_directed, dst(e), src(e))
end

# %% Анализ
source = 1
target = nv(g_directed)
metrics = compute_centrality_metrics(g_directed)

println("Количество узлов: ", nv(g_directed))
println("Количество рёбер: ", ne(g_directed))
println("Топ-5 по in-degree: ", sortperm(metrics[:in_degree], rev=true)[1:5])
println("Топ-5 по PageRank: ", sortperm(metrics[:pagerank], rev=true)[1:5])

# Поиск кратчайшего пути
sp = a_star(g_directed, source, target)
println("Кратчайший путь от 1 до ", target, ": ", isempty(sp) ? "не найден" : sp)

# %% Визуализация (первые 100 узлов)
n_show = 100
sub_v = 1:n_show
pr = metrics[:pagerank][sub_v]
norm_rank = (pr .- minimum(pr)) ./ (maximum(pr) - minimum(pr))
colors = [cgrad(:RdYlGn, rev=true)[norm_rank[i]] for i in 1:n_show]
subg = g_directed[sub_v]
graphplot(subg, nodeshape=:circle, curves=false, linecolor=:black,
          nodecolor=colors, nodelabel=sub_v,
          title="Граф Facebook (первые 100 узлов, цвет = PageRank)", size=(800,600))
savefig(plotsdir("facebook_attack.png"))
println("График сохранён в plots/facebook_attack.png")