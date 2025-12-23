# 运行前环境自检
using Pkg
dependencies = ["Gtk", "Dates", "JSON", "TyPlot", "LinearAlgebra", "Blink"]
for pkg in dependencies
    if !haskey(Pkg.project().dependencies, pkg)
        println("正在安装缺失的包: $pkg")
        Pkg.add(pkg)
    end
end

using Gtk, Dates, JSON
include("Charts.jl")
include("Utils.jl")
include("Dashboard.jl")
import .Charts
import .Utils
import .Dashboard

data = Utils.getData()

# 窗体右边的日历
function calendar()
    calendar_box = GtkBox(:v)
    # 用当前月份的日历只是因为这很方便 
    now_date = today()
    y, m = year(now_date), month(now_date)
    
    lbl_month = GtkLabel("$y 年 $m 月")
    push!(calendar_box, lbl_month)

    grid = GtkGrid()
    set_gtk_property!(grid, :column_homogeneous, true)
    set_gtk_property!(grid, :row_spacing, 5)
    set_gtk_property!(grid, :column_spacing, 5)
    push!(calendar_box, grid)
    
    weeks = ["一", "二", "三", "四", "五", "六", "日"]
    for (i, w) in enumerate(weeks)
        grid[i, 1] = GtkLabel(w)
    end

    first_day = firstdayofmonth(now_date)
    start_col = dayofweek(first_day) 
    days_in_m = daysinmonth(now_date)

    current_day = 1
    for r in 2:7 
        for c in 1:7
            if (r == 2 && c < start_col) || current_day > days_in_m
                continue
            end
            
            btn = GtkButton(string(current_day))
            grid[c, r] = btn
            
            let d = current_day
                signal_connect(btn, "clicked") do widget
                    if d <= length(data)
                        Dashboard.showGUI(data[d])
                        println("正在打开第 $d 日详细分析仪表盘")
                    end
                end
            end
            current_day += 1
        end
    end
    return calendar_box
end

win = GtkWindow("天气分析系统 - 综合看板", 600, 250)
main_hbox = GtkBox(:h) 
push!(win, main_hbox)

# 居中的按钮列表
vbox_left = GtkBox(:v)
set_gtk_property!(vbox_left, :width_request, 180)
set_gtk_property!(vbox_left, :spacing, 10)
push!(main_hbox, vbox_left)

# 居中组件（上）
spacer_top = GtkBox(:v)
set_gtk_property!(spacer_top, :expand, true) # 设置扩展属性
push!(vbox_left, spacer_top)

btns = [
    ("1. 温湿度趋势", Charts.chartTH),
    ("2. 紫外线关联", Charts.chartUT),
    ("3. 风力 & UV", Charts.chartWU),
    ("4. UV 分布图", Charts.chartUD),
    ("5. 温湿度散点图", Charts.chartHT)
]

for (label, func) in btns
    btn = GtkButton(label)
    # 设置水平居中，并给左右留一点边距
    set_gtk_property!(btn, :halign, 3) # 3 表示 GTK_ALIGN_CENTER
    set_gtk_property!(btn, :margin_left, 10)
    set_gtk_property!(btn, :margin_right, 10)
    
    push!(vbox_left, btn)
    signal_connect(btn, "clicked") do widget
        func(data)
    end
end

# 居中组件（下）
spacer_bottom = GtkBox(:v)
set_gtk_property!(spacer_bottom, :expand, true)
push!(vbox_left, spacer_bottom)

# 日历组件
vbox_right = GtkBox(:v)
set_gtk_property!(vbox_right, :margin, 20)
set_gtk_property!(vbox_right, :hexpand, true) 
set_gtk_property!(vbox_right, :valign, 3) # 让右侧日历也在垂直方向居中

calendar_widget = calendar()
push!(vbox_right, calendar_widget)

push!(main_hbox, vbox_right)

# 响应式退出逻辑
if !isinteractive()
    cond = Condition()
    signal_connect(win, :destroy) do widget
        notify(cond)
    end
    wait(cond)
end

showall(win)
