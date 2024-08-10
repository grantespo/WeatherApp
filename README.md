This weather app allows the user to enter a zip code or city to query weather data using the OpenWeather 3.0 api. 

![Simulator Screenshot - iPhone 15 - 2024-08-07 at 04 36 32](https://github.com/user-attachments/assets/e034bb16-28ee-4340-8cca-6ad484162f64)
![Simulator Screenshot - iPhone 15 - 2024-08-07 at 04 38 28](https://github.com/user-attachments/assets/34cc47e5-23e4-4431-8cd3-cd202d6132b8)


# Setup

To run the app, you'll need to add a `Secrets.plist` file to the root of the project. Also, you'll need to add a key `OpenWeatherAPIKey`

# Native Features

- Core Location - User has the option to accept location permissions to automatically query weather data for their current location (instead of typing a city/or zip in the searchbar). Current location can also be queried by tapping the location button in the top right
- Date Picker - User can tap on the date to query weather data for the respective day (Data is available from January 1st, 1979 till 4 days ahead)

# Troubleshooting

If you build the app from Xcode and immediately run it, you may notice the app run slowly for a short time. This seems related to a recent Xcode bug:

https://stackoverflow.com/questions/78129981/logging-error-failed-to-initialize-logging-system-log-messages-may-be-missing

The workaround is to build the app via Xcode, force close the app, then re-open it to see it perform as it would in production.
