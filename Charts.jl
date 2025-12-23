module Charts
    export chartTH, chartUT, chartWU, chartUD, chartHT

using TyPlot, LinearAlgebra
include("Utils.jl")
import .Utils

# 1. 温湿度趋势图
# 趋势图所得到的关系并不显著
function chartTH(data)
    figure("温度与湿度趋势分析"); clf()
    days = [d.day for d in data]
    temp = [Utils.toMid(d.temp) for d in data]
    humi = [Utils.toMid(d.humi) for d in data]

    yyaxis("left"); plot(days, temp, "r-o", label="温度(℃)"); ylabel("温度(℃)")
    yyaxis("right"); plot(days, humi, "b--s", label="湿度(%RH)"); ylabel("湿度(%RH)")
    xlabel("日期/天"); title("温度与湿度时间趋势"); legend(); grid("on")
end

# 2. 紫外线与温度关联
# 紫外线与温度存在显著的正相关
function chartUT(data)
    figure("紫外线与温度关联分析"); clf()
    temp = [Utils.toMid(d.temp) for d in data]
    uv = [Float64(d.uv) for d in data]

    X = [ones(length(temp)) temp]
    coef = X \ uv
    f(x) = coef[1] + coef[2]*x

    xs = LinRange(minimum(temp), maximum(temp), 100)
    plot(xs, f.(xs), "k--", label="趋势线")
    hold("on")
    plot(temp, uv, "ro", label="观测点")
    xlabel("温度(℃)"); ylabel("紫外线指数"); title("紫外线指数与温度关联性"); legend(); grid("on")
    hold("off")
end

# 3. 风力与紫外线对比
# 风力与紫外线存在显著的因果关系（线性正相关），即前一天的风力大会导致后一天紫外线强度大
function chartWU(data)
    figure("风力与紫外线对比"); clf()
    days = [d.day for d in data]
    wind = [Utils.toMid(d.wind) for d in data]
    uv = [d.uv for d in data]

    plot(days, wind, "g-o", label="风力等级")
    hold("on")
    plot(days, uv, "m--s", label="紫外线")
    xlabel("日期/天"); ylabel("等级"); title("风力与紫外线趋势对比"); legend(); grid("on")
    hold("off")
end

# 4. 紫外线等级分布
# 紫外线分布存在正态分布特征
function chartUD(data)
    figure("紫外线等级分布"); clf()
    uv = [d.uv for d in data]
    levels = 1:6
    counts = [count(==(i), uv) for i in levels]

    bar(levels, counts)
    xlabel("紫外线等级"); ylabel("出现天数"); title("紫外线强度等级分布直方图"); grid("on")
end

# 5. 湿度与温度散点图
# 湿度与温度存在显著的线性负相关
function chartHT(data)
    figure("湿温关系散点图"); clf()
    temp = [Utils.toMid(d.temp) for d in data]
    humi = [Utils.toMid(d.humi) for d in data]

    plot(temp, humi, "bo")
    xlabel("温度(℃)"); ylabel("湿度(%RH)"); title("湿度与温度关联散点图"); grid("on")
end

end