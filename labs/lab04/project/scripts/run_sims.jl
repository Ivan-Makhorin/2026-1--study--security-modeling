# # Скрипт run_sims.jl
# Запуск всех симуляций для всех комбинаций параметров.
# Результаты сохраняются в data/sims/results.csv.

using DrWatson
@quickactivate "project"
using DataFrames, CSV

# Подключаем функции из simulation.jl
include(srcdir("simulation.jl"))

# ## Функция запуска одного эксперимента
function run_simulation(params::Dict)
    V = params["V"]
    c_a = params["c_a"]
    c_d = params["c_d"]
    A, D = build_payoff_matrices(V, c_a, c_d)
    eq = mixed_nash_2x2(A, D)
    if eq.type == "pure"
        i = argmax(eq.p)
        j = argmax(eq.q)
        UA = A[i, j]
        UD = D[i, j]
    else
        UA = eq.p' * A * eq.q
        UD = eq.p' * D * eq.q
    end
    return Dict(
        "p_1" => eq.p[1],
        "p_2" => eq.p[2],
        "q_1" => eq.q[1],
        "q_2" => eq.q[2],
        "type" => eq.type,
        "UA" => UA,
        "UD" => UD,
        "V1" => V[1],
        "V2" => V[2],
        "c_a" => c_a,
        "c_d" => c_d,
    )
end

# ## Генерация сетки параметров
function generate_params()
    dicts = []
    for v1 in [5.0, 10.0, 15.0], v2 in [5.0, 10.0, 15.0]
        for c_a in [0.0, 1.0, 3.0], c_d in [0.0, 1.0, 3.0]
            push!(dicts, Dict("V" => [v1, v2], "c_a" => c_a, "c_d" => c_d))
        end
    end
    return dicts
end

# ## Запуск и сохранение
println("Запуск симуляций для всех комбинаций параметров...")
params_list = generate_params()
rows = []
for (i, p) in enumerate(params_list)
    if i % 20 == 0
        println("Обработано $i из $(length(params_list))")
    end
    push!(rows, run_simulation(p))
end
results = DataFrame(rows)
mkpath(datadir("sims"))
CSV.write(datadir("sims", "results.csv"), results)
println("Готово! Сохранено строк: ", nrow(results))