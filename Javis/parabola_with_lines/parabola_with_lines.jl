#using Javis

function ground(args...)
    background("black") # canvas background
    sethue("white") # pen color
end

function object(p=O, color="black")
    sethue(color)
    circle(p, 25, :fill)
    return p
end

function axes(p1,p2,action,color)
    sethue(color)
    return line(p1,p2,action)
end


function pointer(p)
    sethue("red")
    return circle(p,2,:fill)
end

function connector(con,i)
    map(x->line(x[1],x[2],:stroke),con[1:i])
end

function make_animation()

    connection = []

    frames = 200
    npoints = 30
    
    points_x = [Point(-200,x) for x in range(-200,stop = 200,length = npoints)][2:end]
    points_y = [Point(x,200) for x in range(-200,stop = 200,length = npoints)][2:end]

    myvideo = Video(500,500)
    Background(1:frames,ground)

    # make the axes
    yaxis = Object(1:frames,(args...)->axes(Point(-200,-200),Point(-200,200),:stroke,"#03eeff"))
    xaxis = Object(1:frames,(args...)->axes(Point(-200,200),Point(200,200),:stroke,"#03eeff"))
    
    # add some pointers
    Object(1:frames, (args...)->pointer.(points_x))
    Object(1:frames, (args...)->pointer.(points_y))

    # make the connections

    joints = collect(zip(points_x,points_y))
    loop = range(1,stop = frames,length = npoints-1) |> collect .|> x -> round(Int,x)

    for (idx,frame) in enumerate(loop)
        Object(frame:frames,(args...) -> connector(joints,idx))
    end

    render(myvideo; pathname = "parabola_with_lines.gif",framerate = 60)
end

make_animation()
