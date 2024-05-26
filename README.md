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
