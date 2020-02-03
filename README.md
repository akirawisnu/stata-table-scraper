# Stata Table Scraper
Ado file to scrap Table and Array of List and Hyperlinks from website (still in development). 
It's inspired from https://www.ssc.wisc.edu/ of Winsconsin University repo. 

I was using this website for testing: 
https://lovia.life/id/fit/bpjs/area/kab-aceh-selatan (Healthcare facility Addresses and Maps in Indonesia, Aceh Selatan, updated for September 2019)

In order to utilize the tools:
1. Run both do files from your main do file
  example: 
  
  * do "$syntax/0_scraptable.do"
  
2. Run the program: 
Just like Pandas in Python, scraptable.do will do (almost) the same with pandas.read_html() function in Python. 
  * example in Pandas: 
  
  import pandas as pd
  
  link = "https://lovia.life/id/fit/bpjs/area/kab-aceh-selatan"
  
  df = pd.read_html(link)
  
  df = pd.concat(df)
  
  * It will be running the same in Stata with
  
  local link "https://lovia.life/id/fit/bpjs/area/kab-aceh-selatan"
  
  scraptable `link'
  
  Which resulted the same with Pandas one, all as plain text table
  
  * or hmtl option is implemented to preserve hyperlinks and hrefs for geolocation of GMAPS,not native in Python Pandas
  
  scraptable `link', html
  
