# # Скрипт plot_results.jl
# Загружает results.csv и строит два графика:
# 1) p1 vs V1/V2 (c_a=1, c_d=1)
# 2) тепловая карта среднего выигрыша Нападающего

using DrWatson
@quickactivate "project"
using DataFrames, CSV, Plots, StatsPlots, Statistics

# Загрузка результатов
results_path = datadir("sims", "results.csv")
if !isfile(results_path)
    error("Файл результатов не найден. Сначала запустите run_sims.jl")
end
results = CSV.read(results_path, DataFrame)

# Фильтр для фиксированных затрат
filtered = results[(results.c_a .== 1.0) .& (results.c_d .== 1.0), :]
filtered.V1_ratio = filtered.V1 ./ filtered.V2

# График 1: p1 от V1/V2
scatter(filtered.V1_ratio, filtered.p_1,
    group = filtered.type,
    xlabel = "V1 / V2",
    ylabel = "p₁ (вероятность атаки на актив 1)",
    title = "Стратегия Нападающего (c_a=1, c_d=1)",
    legend = :topright,
    markersize = 6)
savefig(plotsdir("p1_vs_ratio.png"))

# График 2: тепловая карта среднего выигрыша
grp = groupby(filtered, [:V1, :V2])
summ = combine(grp, :UA => mean => :UA_mean)
heatmap(sort(unique(summ.V1)), sort(unique(summ.V2)),
    (x,y) -> summ[(summ.V1 .== x) .& (summ.V2 .== y), :UA_mean][1],
    xlabel = "V1", ylabel = "V2",
    title = "Средний выигрыш Нападающего",
    color = :viridis)
savefig(plotsdir("heatmap_UA.png"))

println("Графики сохранены: ")
println("  ", plotsdir("p1_vs_ratio.png"))
println("  ", plotsdir("heatmap_UA.png"))