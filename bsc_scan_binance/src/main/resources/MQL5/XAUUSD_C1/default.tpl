<chart>
id=133703198761338605
comment=(2024.09.09 17:10)    (D1) XAUUSDc    Init: 0.01 lot, next: 0.03 lot by fibo: 2.618    R1%: 1 $    Amp(H4): 6.295    Amp(D1): 31.359    Amp(W1): 83.539 (83.539)/10    m.L.B: 0L    m.TP.B: 0.00$    m.DD.B: 0.00$                m.L.S: 1L    m.TP.S: 0.00$   
symbol=XAUUSDc
period=1440
leftpos=1745
digits=3
scale=8
graph=2
fore=0
grid=0
volume=0
scroll=1
shift=1
ohlc=0
one_click=0
one_click_btn=0
askline=1
days=0
descriptions=0
shift_size=20
fixed_pos=32
window_left=128
window_top=128
window_right=2894
window_bottom=876
window_type=3
background_color=16777215
foreground_color=0
barup_color=4294967295
bardown_color=4294967295
bullcandle_color=4294967295
bearcandle_color=4294967295
chartline_color=4294967295
volumes_color=32768
grid_color=4294967295
askline_color=17919
stops_color=17919

<window>
height=203
fixed_height=0
<indicator>
name=main
</indicator>
<indicator>
name=Moving Average
period=10
shift=0
method=0
apply=0
color=255
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=20
shift=0
method=0
apply=0
color=16711680
style=0
weight=2
period_flags=127
show_data=1
</indicator>
<indicator>
name=Moving Average
period=50
shift=0
method=0
apply=0
color=6908265
style=0
weight=3
period_flags=63
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=Heiken Ashi
flags=275
window_num=0
<inputs>
ExtColor1=0
ExtColor2=0
ExtColor3=6908265
ExtColor4=8421376
</inputs>
</expert>
shift_0=0
draw_0=2
color_0=0
style_0=0
weight_0=1
shift_1=0
draw_1=2
color_1=0
style_1=0
weight_1=1
shift_2=0
draw_2=2
color_2=6908265
style_2=0
weight_2=3
shift_3=0
draw_3=2
color_3=8421376
style_3=0
weight_3=3
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=5
shift=0
method=0
apply=0
color=7346457
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=3
shift=0
method=0
apply=0
color=0
style=0
weight=1
period_flags=128
show_data=1
</indicator>
</window>

<window>
height=51
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=MACD
flags=275
window_num=3
<inputs>
InpFastEMA=12
InpSlowEMA=26
InpSignalSMA=9
</inputs>
</expert>
shift_0=0
draw_0=2
color_0=16119285
style_0=0
weight_0=4
shift_1=0
draw_1=0
color_1=0
style_1=0
weight_1=2
levels_color=0
levels_style=4
levels_weight=1
level_0=0.00000000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=31
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=Stochastic
flags=275
window_num=1
<inputs>
InpKPeriod=288
InpDPeriod=48
InpSlowing=10
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=8421376
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=2
min=0.00000000
max=100.00000000
levels_color=0
levels_style=0
levels_weight=1
level_0=20.00000000
level_1=80.00000000
period_flags=2
show_data=0
</indicator>
<indicator>
name=Stochastic Oscillator
kperiod=21
dperiod=7
slowing=7
method=0
apply=0
color=255
style=0
weight=2
color2=0
style2=0
weight2=2
min=0.00000000
max=100.00000000
levels_color=12632256
levels_style=2
levels_weight=1
level_0=20.00000000
level_1=80.00000000
period_flags=242
show_data=1
</indicator>
</window>

<window>
height=49
fixed_height=0
<indicator>
name=Stochastic Oscillator
kperiod=35
dperiod=10
slowing=7
method=0
apply=0
color=255
style=0
weight=2
color2=0
style2=0
weight2=2
min=0.00000000
max=100.00000000
levels_color=0
levels_style=2
levels_weight=1
level_0=20.00000000
level_1=80.00000000
period_flags=0
show_data=1
</indicator>
</window>

<expert>
name=X100_C1
flags=279
window_num=0
</expert>
</chart>

