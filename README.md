# Venro
This Perl script is designed to extract JavaScript endpoints from one or more JavaScript files specified by URLs. Here's a breakdown of what the script does:
It uses the LWP::UserAgent module to fetch the content of JavaScript files from the specified URLs.
The script reads regex patterns from a file named regex.tmp and applies them to the fetched JavaScript content to extract potential endpoints.
It filters the extracted matches to remove unwanted strings and invalid characters.
The script can save the extracted endpoints to an output file specified by the user.
The script supports two modes of operation:
Single JavaScript file mode: The user specifies a single JavaScript file URL using the -u option.
Multiple JavaScript file mode: The user specifies a text file containing a list of JavaScript file URLs using the -l option.
The script uses threads to fetch and process multiple JavaScript files concurrently, improving performance.
It displays the time taken to process all the JavaScript files.
# Installation

```
https://github.com/XJOKZVO/Venro.git
```

# Options:
```
   __     __                              
 \ \   / /   ___   _ __    _ __    ___  
  \ \ / /   / _ \ | '_ \  | '__|  / _ \ 
   \ V /   |  __/ | | | | | |    | (_) |
    \_/     \___| |_| |_| |_|     \___/ 
                                        
Usage: Venro.pl [options]
Options:
    -l <file>   .txt file containing JavaScript file URLs
    -u <url>    Single JavaScript file direct URL
    -o <file>   Output file to save endpoints
    -h          Display this help message

Please use one of -u for a single JS file URL or -l for a .txt file containing JS file URLs.
```

# Usage:
```
To run the script with a single JavaScript file URL:
perl Venro.pl -u https://example.com/script.js

To run the script with a text file containing multiple JavaScript file URLs:
perl Venro.pl -l urls.txt

To save the extracted endpoints to an output file:
perl Venro.pl -l urls.txt -o output.txt
```
