# Household Water Leak and Usage Analyzer

A web-based household water consumption analyzer built with **R** and **Shiny**. The app lets users enter daily water readings, highlights unusually high usage, estimates monthly consumption and cost, and displays a chart.

## Features

- Enter 14 days of water usage in litres
- Calculate total, average, minimum, and maximum usage
- Flag unusually high readings using a median-based threshold
- Estimate 30-day water usage and the approximate bill
- View a daily consumption chart and usage table
- Reset the app to the sample data
- Display practical water-saving suggestions

## Built With

- R
- Shiny
- Base R plotting functions

## Run Locally

1. Install [R](https://www.r-project.org/).
2. Open R or RStudio.
3. Install Shiny (one time):

   ```r
   install.packages("shiny")
   ```

4. Download or clone this repository.
5. Set the working directory to the repository folder, or open the folder in RStudio.
6. Run:

   ```r
   shiny::runApp()
   ```

The app should open in your web browser.

## How the Sample Analysis Works

The included sample contains 14 daily readings. The app uses 1.5 times the median reading as a simple threshold for flagging unusually high consumption. Monthly usage is estimated as average daily usage multiplied by 30. The estimated bill is calculated using the user-entered price per kilolitre.

**Important:** A high reading is only a warning to investigate and does not prove that a physical leak exists. The default water tariff is illustrative; enter the applicable local tariff for a more realistic estimate.

## Project Structure

```text
Household-Water-Analyzer/
├── app.R
└── README.md
```

## Future Improvements

- Save daily readings to a CSV file or database
- Compare weekly and monthly trends
- Export analysis reports
- Add user accounts or multiple household profiles
- Integrate real water-meter readings

## Author

Add your name and institution here.
