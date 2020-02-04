"""
"""
function sample_clicks(ntrials::Int; rng::Int=1)
    
    Random.seed!(rng)
    
    data = Dict()

    output = map(generate_stimulus,1:ntrials)

    data["leftbups"] = map(i->output[i][3],1:ntrials)
    data["rightbups"] = map(i->output[i][2],1:ntrials)
    data["T"] = map(i->output[i][1],1:ntrials)
    data["correct"] = map(i->output[i][4], 1:ntrials)
    data["gamma"] = map(i->output[i][5], 1:ntrials)
    data["ntrials"] = ntrials
    
    return data
    
end


"""
"""
function generate_stimulus(i::Int; tmin::Float64=10.0,tmax::Float64=10.0,clickrate::Int=40)
    
    T = tmin + (tmax-tmin)*rand()
    clicktot = clickrate*Int(ceil.(T))
    
    # these values correspond to a gamma of (-) 0.5, 1.5, 2.5 and 3.5
    # gamma = 3.5
    # r = (clickrate*exp(gamma))./(1+exp(gamma))
    Rbar = rand((15.10, 24.89, 7.29, 32.7, 3.03, 36.96, 1.17, 38.82))
    Lbar = clickrate - Rbar

    R = cumsum(rand(Exponential(1/Rbar),clicktot))
    L = cumsum(rand(Exponential(1/Lbar),clicktot))
    R = vcat(0,R[R .<= T])
    L = vcat(0,L[L .<= T])
    
    T = ceil.(T, digits=2)
    correct = Bool(Rbar > Lbar)
    gamma = round(log(Rbar/Lbar), digits =1)

    return T,R,L,correct, gamma
    
end


"""
"""
function sample_latent(nT::Int, L::Vector{Float64},R::Vector{Float64},
        nL::Vector{Int}, nR::Vector{Int}, 
        pz::Vector{TT}, use_bin_center::Bool; 
        dt::Float64=1e-4) where {TT <: Any}
    
    σ2_i, B, λ, σ2_a, σ2_s, ϕ, τ_ϕ = pz
    La, Ra = make_adapted_clicks(ϕ, τ_ϕ, L, R)

    A = Vector{TT}(undef,nT)
    RT = 0 

    a = sqrt(σ2_i)*randn()

    for t = 1:nT
            
        if use_bin_center && t == 1         
            a = sample_one_step!(a, t, σ2_a, σ2_s, λ, nL, nR, La, Ra, dt/2)
        else
            a = sample_one_step!(a, t, σ2_a, σ2_s, λ, nL, nR, La, Ra, dt)
        end

        abs(a) > B ? (a = B * sign(a); A[t:nT] .= a; RT = t; break) : A[t] = a
	
	# this should be handles in a better way, but for now to prevent fatal errors
	if t == nT
	     RT = t
	end 

    end               
    
    return A, RT
    
end


"""
"""
function sample_one_step!(a::TT, t::Int, σ2_a::TT, σ2_s::TT, λ::TT, 
        nL::Vector{Int}, nR::Vector{Int}, 
        La, Ra, dt::Float64) where {TT <: Any}
    
    any(t .== nL) ? sL = sum(La[t .== nL]) : sL = zero(TT)
    any(t .== nR) ? sR = sum(Ra[t .== nR]) : sR = zero(TT)
    σ2, μ = σ2_s * (sL + sR), -sL + sR  
    
    η = sqrt(σ2_a * dt + σ2) * randn()
    
    if abs(λ) < 1e-150 
        a += μ + η
    else
        h = μ/(dt*λ)
        a = exp(λ*dt)*(a + h) - h + η
    end
    
    return a

end
