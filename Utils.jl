module Utils
    export toMid, loadData

using JSON

# 取中位数
# @param s 带有~的String
function toMid(s::String)
    s_clean = replace(string(s), " " => "")
    if contains(s_clean, "~")
        vals = parse.(Float64, split(s_clean, "~"))
        return sum(vals) / length(vals)
    else
        return parse(Float64, s_clean)
    end
end

function loadData(filepath)
    raw_data = JSON.parsefile(filepath)
    # 转换为NamedTuple数组，以匹配charts.jl里的d.day, d.temp的写法
    # 我们将每个Dict的Key转换为Symbol
    formatted_data = [
        (
            day=item["day"],
            temp=item["temp"],
            humi=item["humi"],
            wind=item["wind"],
            uv=item["uv"]
        )
        for item in raw_data
    ]

    return formatted_data
end

data = loadData("weather_data.json")

function getData()
    return data;
end

end