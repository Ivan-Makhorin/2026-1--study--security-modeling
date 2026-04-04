# # Дополнительные функции для моделирования потоков
# 
# В этом модуле реализованы:
# - нестационарный пуассоновский поток (метод прореживания)
# - прореженный пуассоновский поток (успешность атак)
# - подсчёт событий по временным окнам
# 

using Distributions

# ## Нестационарный пуассоновский поток

function simulate_nonhomogeneous_poisson(λ_func, T; λ_max=nothing)
    #= Оцениваем максимум интенсивности, если не задан =#
    if λ_max === nothing
        grid = 0:0.01:T
        λ_max = maximum(λ_func.(grid))
    end
    events = Float64[]
    t = 0.0
    while t < T
        t += rand(Exponential(1/λ_max))
        if t <= T && rand() <= λ_func(t) / λ_max
            push!(events, t)
        end
    end
    return events
end

# ## Подсчёт событий в окнах фиксированной длины

function count_events_in_windows(events, window_duration, T)
    n_windows = ceil(Int, T / window_duration)
    counts = zeros(Int, n_windows)
    for e in events
        idx = floor(Int, e / window_duration) + 1
        if idx <= n_windows
            counts[idx] += 1
        end
    end
    return counts
end

# ## Прореженный пуассоновский поток (успешные атаки)

function simulate_thinned_poisson(λ, T, p)
    intervals = Float64[]
    total_time = 0.0
    while total_time < T
        τ = rand(Exponential(1/λ))
        push!(intervals, τ)
        total_time += τ
    end
    if total_time > T
        pop!(intervals)
    end
    all_times = cumsum(intervals)
    success_mask = rand(length(all_times)) .< p
    success_times = all_times[success_mask]
    return (all_times = all_times, success_times = success_times, p = p, λ = λ, T = T)
end