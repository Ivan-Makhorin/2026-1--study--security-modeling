# # Модуль симуляции пуассоновского потока атак
# 
# В этом модуле реализованы функции для генерации простейшего потока событий.
# 
# ## Подключаемые пакеты
using Distributions
using Statistics

# ## Основная функция симуляции
# 
# ### `simulate_attacks(λ::Float64, T::Float64)`
# 
# Генерирует реализацию пуассоновского потока атак с интенсивностью `λ` (атак/час) на интервале `[0, T]` (часов).
# Возвращает NamedTuple с полями:
# - `hourly_counts` : массив числа атак за каждый целый час (длина floor(T))
# - `intervals`     : массив интервалов между атаками (экспоненциальные)
# - `attack_times`  : массив моментов времени атак (накопленные суммы)
function simulate_attacks(λ::Float64, T::Float64)
    # Почасовое число атак – распределение Пуассона
    hourly_counts = rand(Poisson(λ), floor(Int, T))

    # Моделирование точных моментов через экспоненциальные интервалы
    intervals = Float64[]
    total_time = 0.0
    while total_time < T
        τ = rand(Exponential(1/λ))
        push!(intervals, τ)
        total_time += τ
    end
    # Удаляем последнее событие, если оно вышло за пределы T
    if total_time > T
        pop!(intervals)
    end
    attack_times = cumsum(intervals)

    return (hourly_counts = hourly_counts,
            intervals = intervals,
            attack_times = attack_times)
end

# Обёртка для вызова из скрипта с параметрами-словарём
function simulate_attacks(p::Dict)
    return simulate_attacks(p[:λ], p[:T])
end

# ## Дополнительные функции для дополнительных заданий (см. далее)