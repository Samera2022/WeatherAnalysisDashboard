module Dashboard
    export showGUI;

using Blink, JSON
include("Utils.jl")
import .Utils    

# 穿衣公式计算函数
# @param t 温度
# @param w 风力
function clothing(t, w)
    # 定义衣服属性库 (热值, 名称, 层级: 1贴身, 2保暖, 3外套)
    db = [
        (1, "吊带/T恤", 1), (2, "衬衫", 1), (2, "长袖T恤", 1),
        (3, "开衫/针织衫", 2), (6, "羊绒衫", 2), (7, "高领厚羊毛衫", 2),
        (4, "棒球衫/牛仔衣", 3), (4, "西装", 3), (6, "风衣/皮衣", 3), 
        (6, "呢外套", 3), (8, "厚款大衣", 3), (10, "薄款羽绒服", 3), (12, "长款厚羽绒服", 3)
    ]

    # 计算目标补丁温度：23℃ - 当前气温 + 风力补偿
    extra_wind = w >= 5 ? 3 : 0
    target = 23 - t + extra_wind
    
    outfit = String[]
    current_val = 0

    # 如果缺口小于等于最低热值(1℃)，判定为不需要补丁
    if target <= 1.0
        status = "天气炎热"
        items = "无需额外保暖（短袖/凉快装扮）"
        current_val = 0 
    else
        # 正常匹配逻辑：内层 -> 外套 -> 中层
        inner = t > 25 ? db[2] : db[3] 
        push!(outfit, inner[2])
        current_val += inner[1]

        # 简单的贪心
        gap = target - current_val
        if gap >= 4
            outers = filter(x -> x[3] == 3, db)
            best_o = outers[findmin([abs(x[1] - gap) for x in outers])[2]]
            push!(outfit, best_o[2])
            current_val += best_o[1]
        end

        gap = target - current_val
        if gap >= 3
            mids = filter(x -> x[3] == 2, db)
            best_m = mids[findmin([abs(x[1] - gap) for x in mids])[2]]
            push!(outfit, best_m[2])
            current_val += best_m[1]
        end

        status = t >= 15 ? "春秋凉意" : "冬日严寒"
        items = join(outfit, " + ")
    end

    return status, items, round(target, digits=1), current_val
end

# 气象分析建议
function analyze(t, h, w, uv)
    # 计算体感温度 (考虑湿度影响)
    apparent_t = t + (0.05 * h) - 2.0
    
    tags = String[]
    status = if apparent_t > 27 "体感闷热" elseif apparent_t < 13 "体感寒冷" else "体感舒适" end

    # 风险判定
    if uv >= 6 push!(tags, "紫外线极强")
    elseif uv >= 4 push!(tags, "紫外线较强") end
    if w >= 5 push!(tags, "大风预警") end
    if t > 25 && h > 75 push!(tags, "中暑风险高") end
    if w <= 2 && h > 80 push!(tags, "湿闷无风") end

    risk_info = isempty(tags) ? 
        ">当日$(status)，各指标均衡，非常适合户外活动。" : 
        ">当日$(status)。<br>风险提示：【" * join(tags, " / ") * "】<br>>建议减少长途运动，注意防护。"

    status = status * " (体感温度约为$(round(apparent_t, digits=1))℃)"    
    return status, risk_info
end

function showGUI(data::NamedTuple)
    t_mid = Utils.toMid(data.temp)
    h_mid = Utils.toMid(data.humi)
    w_mid = Utils.toMid(data.wind)
    uv_val = data.uv
    
    # 获取计算数据
    c_status, c_items, c_target, c_real = clothing(t_mid, w_mid)
    eval_status, eval_detail = analyze(t_mid, h_mid, w_mid, uv_val)

    # CSS窗体会导致加载速度减慢，但是没有更好的方案了
    html_page = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="GBK">
        <style>
            body { font-family: 'Microsoft YaHei', sans-serif; background: #2c3e50; color: white; display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100vh; margin: 0; }
            .main-header { font-size: 24px; font-weight: bold; margin-bottom: 20px; color: #ecf0f1; }
            .main-content { display: flex; align-items: flex-start; gap: 25px; }
            
            .container { background: #34495e; padding: 25px; border-radius: 15px; display: flex; gap: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.3); }
            .indicator { display: flex; flex-direction: column; align-items: center; width: 75px; }
            .bar-bg { width: 28px; height: 180px; background: #222; border-radius: 14px; position: relative; display: flex; align-items: flex-end; overflow: hidden; }
            .bar-fill { width: 100%; transition: height 0.6s ease-out; border-radius: 0 0 14px 14px; }
            
            .side-panel { display: flex; flex-direction: column; gap: 15px; width: 320px; }
            .info-card { padding: 18px; border-radius: 12px; box-shadow: 0 6px 12px rgba(0,0,0,0.2); height: auto; }
            .cloth-theme { background: #1abc9c; }
            .eval-theme { background: #3498db; }
            
            .card-title { font-size: 16px; font-weight: bold; margin-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 4px; }
            .card-content { font-size: 13px; line-height: 1.6; }
            .math-note { font-family: Consolas, monospace; font-size: 11px; opacity: 0.9; margin-top: 5px; color: #f1c40f; }

            .t-fill { background: #e67e22; height: $((t_mid / 35) * 180)px; }
            .h-fill { background: #3498db; height: $(h_mid)%; }
            .w-fill { background: #2ecc71; height: $((w_mid / 5) * 180)px; }
            .u-fill { background: #9b59b6; height: $((uv_val / 6) * 180)px; }
            
            .label { margin-top: 10px; font-size: 14px; font-weight: bold; }
            .val-text { font-size: 11px; color: #bdc3c7; }
        </style>
    </head>
    <body>
        <div class="main-header">第 $(data.day) 日气象智能看板</div>
    
        <div class="main-content">
            <div class="container">
                <div class="indicator"><div class="bar-bg"><div class="bar-fill t-fill"></div></div><div class="label">温度</div><div class="val-text">$(data.temp)℃</div></div>
                <div class="indicator"><div class="bar-bg"><div class="bar-fill h-fill"></div></div><div class="label">湿度</div><div class="val-text">$(data.humi)%</div></div>
                <div class="indicator"><div class="bar-bg"><div class="bar-fill w-fill"></div></div><div class="label">风力</div><div class="val-text">$(data.wind)级</div></div>
                <div class="indicator"><div class="bar-bg"><div class="bar-fill u-fill"></div></div><div class="label">紫外线</div><div class="val-text">指数 $(uv_val)</div></div>
            </div>

            <div class="side-panel">
                <div class="info-card cloth-theme">
                    <div class="card-title">👔 穿衣公式现场匹配</div>
                    <div class="card-content">
                        <b>分类建议：</b>$(c_status)<br>
                        <b>推荐组合：</b>$(c_items)<br>
                        <div class="math-note">缺口: $(c_target)℃ / 已补: $(c_real)℃</div>
                    </div>
                </div>

                <div class="info-card eval-theme">
                    <div class="card-title">📊 气象综合诊断</div>
                    <div class="card-content">
                        <b>诊断结论：</b>$(eval_status)<br>
                        $(eval_detail)
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
    """
    w = Blink.Window()
    Blink.size(w, 900, 450)
    Blink.body!(w, html_page)
end

end