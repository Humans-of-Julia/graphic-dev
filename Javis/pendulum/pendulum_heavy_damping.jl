using Animations
using Javis
using OrdinaryDiffEq

#Constants
const g = 9.81
L = 1.0

#Initial Conditions
u₀ = [0,π]
tspan = (0.0,10)

#Define the problem
function simplependulum(du,u,p,t)
    θ = u[1]
    dθ = u[2]
    du[1] = dθ
    # to change the damping change the number that multiplies `dθ` to
    # 0.5 for heavy damping
    # 0.05 for light damping
    du[2] = -0.5 * dθ -(g/L) * sin(θ)
end

#Pass to solvers
prob = ODEProblem(simplependulum, u₀, tspan)
sol = solve(prob,Tsit5(),saveat = 0.1)

theta = pi/2 .+ getindex.(sol.u,1)

start_pos = [Point(0,-200) for _ in 1:length(theta)]
end_pos = [Point(0+200*cos(x),-200+200*sin(x)) for x in theta]

function rod(p1,p2,color)
    sethue(color)
    line(p1,p2,:stroke)
end

function ground(args...)
    background("black") # canvas background
    sethue("white") # pen color
end

function object(p, color, r)
    sethue(color)
    circle(p, r, :fill)
    return p
end


function make_animation()

    nframes = 700
    frame_size = 400
    vid = Video(frame_size,frame_size)
    Background(1:nframes,ground)
    
    # define all the objects
    top_bar = Object(1:nframes,(args...) -> line(Point((frame_size/2 - 50),-(frame_size/2 - 50)),Point(-(frame_size/2 - 50),-(frame_size/2 - 50)),:stroke))
    support = Object(1:nframes, (args...) -> object(Point(0,-(frame_size/2 - 50)),"white",6))
    blob = Object(1:nframes,(args...) -> object(end_pos[1],"red",10))
    
    blob_anim = Animation(
        range(0,stop = 1,length = length(theta)),
        end_pos,
        [linear() for _ in 1:(length(theta) - 1)]
    )
    
    act!(blob,Action(1:nframes,blob_anim,translate()))

    Object(1:nframes, (args...) -> rod(Point(0,-(frame_size/2 - 50)), pos(blob), "white"))

    Object(1:nframes,(args...) -> text("pendulum with heavy damping",Point(-75,-(frame_size/2 - 35))))
    
    render(
        vid;
        pathname = "pendulum/pendulum_heavy_damping.gif"
    )

end

make_animation()