using LinearAlgebra

function build_payoff_matrices(V::Vector{Float64}, c_a::Float64, c_d::Float64)
    n = length(V)
    A = zeros(n, n)
    D = zeros(n, n)
    for i in 1:n, j in 1:n
        if i != j
            A[i, j] = V[i] - c_a
            D[i, j] = -V[i] - c_d
        else
            A[i, j] = -c_a
            D[i, j] = -c_d
        end
    end
    return A, D
end

function mixed_nash_2x2(A::Matrix{Float64}, D::Matrix{Float64})

    for i in 1:2, j in 1:2
        if A[i, j] >= A[3-i, j] && D[i, j] >= D[i, 3-j]
            p = zeros(2); p[i] = 1.0
            q = zeros(2); q[j] = 1.0
            return (p = p, q = q, type = "pure")
        end
    end

    denomA = (A[1,1] - A[2,1]) - (A[1,2] - A[2,2])
    if abs(denomA) > 1e-10
        q1 = (A[2,2] - A[1,2]) / denomA
        q1 = clamp(q1, 0.0, 1.0)
    else
        q1 = 0.5
    end
    q = [q1, 1 - q1]

    denomD = (D[1,1] - D[1,2]) - (D[2,1] - D[2,2])
    if abs(denomD) > 1e-10
        p1 = (D[2,2] - D[2,1]) / denomD
        p1 = clamp(p1, 0.0, 1.0)
    else
        p1 = 0.5
    end
    p = [p1, 1 - p1]
    return (p = p, q = q, type = "mixed")
end
