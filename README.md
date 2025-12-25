# Weather Analysis Dashboard

A Julia-powered weather analysis dashboard for college homework.

Note: Only version v0.0.6 is uploaded because the project was not initially intended for GitHub.

## Features

### GUI Support
- **Windowed Operation**: Replaces terminal-based input/output with a complete graphical interface, significantly lowering the barrier for non-technical users.
- **Responsive Layout**: Adopts a left-right split design for clear logic separation—long-term macro analysis on the left and single-point micro analysis on the right.
- **Dynamic Interaction**: Uses signal handling to map user operations to backend functions in real time, enabling seamless "static display" to "dynamic interaction" transition.

<div align="center">
  <img src="https://raw.githubusercontent.com/Samera2022/WeatherAnalysisDashboard/main/pics/1.1.png">
</div>

### Json Input Support
- **Decoupled Design**: Fully decouples program logic from raw data—"deploy once, use permanently". Simply replace the `weather_data.json` file to analyze new data without modifying code.
- **Robust Data Processing**: Implements the `toMid` function with regex-based parsing to handle irregular range data (e.g., temperature "15~22℃") by converting it to floating-point medians.

<div align="center">
  <img src="https://raw.githubusercontent.com/Samera2022/WeatherAnalysisDashboard/main/pics/1.2.png">
</div>

### Calendar-style Data Interface
- **Visual Timeline**: Converts abstract data points into an intuitive calendar view for clear data record visualization.
- **Drill-down Functionality**: Each date button serves as an independent entry—click to analyze detailed weather conditions for that specific day.

<div align="center">
  <img src="https://raw.githubusercontent.com/Samera2022/WeatherAnalysisDashboard/main/pics/1.3.png">
</div>

### Useful Daily Functions
- **Smart Clothing Recommendation**: Calculates optimal outfits using a "heat value" system for clothing items, combined with temperature and wind speed data (targeting 23℃ comfort).
- **Apparant Temperature Model**: Incorporates humidity correction factors to calculate real perceived temperature, aligning with actual living experiences.
- **Risk Warning System**: Provides personalized suggestions based on daily risk indicators (e.g., UV intensity) for one-click decision support.
- **Weather Dashboard**: Uses Blink's WebView for advanced component rendering and an elegant interface display.

<div align="center">
  <img src="https://raw.githubusercontent.com/Samera2022/WeatherAnalysisDashboard/main/pics/1.4.png">
</div>

### Multi-Dimension Charts Support
- **Temperature & Humidity Trend Analysis**: Dual Y-axis coordinate system to compare temperature and humidity, intuitively revealing their covariant relationship.
- **Scientific Modeling**: Integrates least squares linear regression to establish trend lines between UV index and temperature.
- **Comprehensive Visualization**: Covers line charts (trends), scatter plots (correlations), and histograms (distributions) for full data representation.

<div align="center">
  <img src="https://raw.githubusercontent.com/Samera2022/WeatherAnalysisDashboard/main/pics/1.5.png">
</div>

## Key Analysis Conclusions
1. **Temperature-Humidity Correlation**: Significant linear negative correlation, explained by temperature's influence on water evaporation and vegetation transpiration.
2. **Temperature-UV Correlation**: Significant linear positive correlation, attributed to temperature's impact on cloud cover.
3. **Wind-UV Correlation**: Significant causal relationship (linear positive correlation), also explained by temperature-driven cloud cover changes.
4. **UV Distribution**: Ultraviolet intensity levels follow a roughly normal distribution pattern.

## Technical Implementation
| Feature Category       | Technical Details                                                                 |
|------------------------|-----------------------------------------------------------------------------------|
| GUI Development        | Gtk-based container layout (GtkBox(:h) for main container, nested GtkBox(:v) for vertical alignment) |
| Data Handling          | JSON parsing with `parsefile` for NamedTuple mapping and serialization; regex for irregular data processing |
| Calendar Component     | Dates.jl for weekday calculation and layout; button-loop binding for date-data mapping |
| Daily Functions        | Greedy algorithm for clothing recommendation; meteorological humidity correction for feels-like temperature |
| Chart Generation       | Dual Y-axis design; least squares regression; multi-type chart rendering (line/scatter/histogram) |

## Challenges & Solutions
### Technical Challenges
- **GUI Ecosystem Limitation**: Julia's emerging GUI ecosystem is relatively underdeveloped, making interface design more challenging than Java.
- **Packaging Difficulties**: Encountered thousands of lines of error logs during packaging, requiring extensive debugging.

### Practical Solutions
- Adopted Gtk for GUI development with signal handling to ensure basic interactive functionality.
- Used simple folder-based version control (v0.0.0 to v0.0.6) instead of Git due to project simplicity.
- Iterative testing and incremental version updates to address packaging issues gradually.

## Project Structure
```
JuliaHomework/
├── src/
│ ├── frame.jl # Main GUI frame and layout
│ ├── charts.jl # Chart generation logic
│ ├── dashboard.jl # Weather dashboard rendering
│ ├── FileReader.jl # JSON data reading
│ └── Utils.jl # Utility functions (data processing, calculations)
├── weather_data.json # Input data file (replaceable)
├── Manifest.toml # Project dependency configuration (Not Uploaded this time, you may need to do it by yourself)
└── Project.toml # Julia project file (Not Uploaded this time, you may need to do it by yourself)
```

## Usage
1. Prepare your weather data in JSON format (follow the structure in `weather_data.json` with fields: day, temp, humi, wind, uv).
2. Replace the existing `weather_data.json` file with your custom data (no code modifications needed).
3. Run `Frame.jl` to launch the application.
4. Use the calendar interface to navigate dates, view macro trends on the left panel, and access detailed daily analysis (clothing recommendations, feels-like temperature, risk warnings) on the right panel.
5. Switch between different chart views via the function buttons to explore multi-dimensional data correlations.

## Dependencies
- Julia v1.9+
- Gtk.jl 
- Dates.jl 
- Blink.jl 
- JSON.jl 
- LinearAlgebra.jl 
- TyPlot.jl (Tongyuan Plot, included in MWorks environment by default. You may need to replace it by Plots.jl in cases where MWorks are not used)

## Notes
- Dependencies Installation is included in the Frame.jl. Or you can install all dependencies via Julia's Pkg manager: `] add Gtk Dates Blink JSON LinearAlgebra Plots`
- The input JSON file supports irregular data formats (e.g., "15~22" for temperature) – the system will automatically process and normalize the data.
- Only version v0.0.6 is uploaded to this repository; earlier versions are for internal development tracking only.
- For best performance, ensure the JSON file contains continuous date data (e.g., full-month records) to enable comprehensive trend analysis.