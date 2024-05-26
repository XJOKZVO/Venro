#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use Getopt::Long;
use File::Basename;
use threads;
use Thread::Queue;

# ASCII art header
print <<'END_ASCII';
 __     __                              
 \ \   / /   ___   _ __    _ __    ___  
  \ \ / /   / _ \ | '_ \  | '__|  / _ \ 
   \ V /   |  __/ | | | | | |    | (_) |
    \_/     \___| |_| |_| |_|     \___/ 
                                        
END_ASCII

my $numeric_exted_eps = 1;
my $timeout = 7;
my $ua = LWP::UserAgent->new(timeout => $timeout);
$ua->agent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:125.0) Gecko/20100101 Firefox/125.0');

sub get_file_content {
    my $url = shift;
    my $response = $ua->get($url);
    if ($response->is_success) {
        return ($response->decoded_content, 1);
    }
    return ('', 0);
}

sub read_regex_patterns {
    my $filename = shift;
    open(my $fh, '<', $filename) or die "Could not open file '$filename': $!";
    my @patterns;
    while (my $line = <$fh>) {
        chomp $line;
        push @patterns, qr/$line/;
    }
    close $fh;
    return @patterns;
}

sub apply_regexes {
    my ($content, @regexes) = @_;
    my @all_matches;
    foreach my $regex (@regexes) {
        push @all_matches, ($content =~ /$regex/g);
    }
    return @all_matches;
}

sub is_valid_match {
    my $match = shift;
    my @unwanted_strings = ('"/$"', '"/*"', '"?"', '"/"', '"//"', '`/`', '===');
    foreach my $u (@unwanted_strings) {
        return 0 if $match eq $u || $match =~ /===/;
    }
    return $match !~ /[:;{},()|[\]!<>^*+ ]/;
}

sub append_text_to_file {
    my ($filename, $content) = @_;
    open(my $fh, '>>', $filename) or die "Could not open file '$filename': $!";
    print $fh "$content\n";
    close $fh;
}

sub extract {
    my ($url, $output_file) = @_;
    my ($content, $valid) = get_file_content($url);
    unless ($valid) {
        print "[ ! ] urlFile is not valid or accessible : $url\n";
        return;
    }

    my @regexes = read_regex_patterns('regex.tmp');
    my @matches = apply_regexes($content, @regexes);
    my %seen;
    foreach my $match (@matches) {
        if (is_valid_match($match) && !$seen{$match}) {
            printf("[ %d ] %s : %s\n", $numeric_exted_eps, $url, $match);
            append_text_to_file($output_file, "$url : $match") if $output_file;
            $seen{$match} = 1;
            $numeric_exted_eps++;
        }
    }
}

sub print_help {
    print <<'END_HELP';
Usage: Venro.pl [options]
Options:
    -l <file>   .txt file containing JavaScript file URLs
    -u <url>    Single JavaScript file direct URL
    -o <file>   Output file to save endpoints
    -h          Display this help message

Please use one of -u for a single JS file URL or -l for a .txt file containing JS file URLs.
END_HELP
}

sub main {
    my $flag_js_file;
    my $flag_single_js_file;
    my $flag_output_file;
    my $flag_help;

    GetOptions(
        'l=s' => \$flag_js_file,
        'u=s' => \$flag_single_js_file,
        'o=s' => \$flag_output_file,
        'h'   => \$flag_help,
    );

    if ($flag_help) {
        print_help();
        exit;
    }

    unless (($flag_js_file && !$flag_single_js_file) || (!$flag_js_file && $flag_single_js_file)) {
        print_help();
        die "Please use one of -u for a single JS file URL or -l for a .txt file containing JS file URLs.\n";
    }

    my $start_time = time();
    my $queue = Thread::Queue->new();

    if ($flag_js_file) {
        open(my $fh, '<', $flag_js_file) or die "Could not open file '$flag_js_file': $!";
        while (my $line = <$fh>) {
            chomp $line;
            $queue->enqueue($line);
        }
        close $fh;
    } elsif ($flag_single_js_file) {
        $queue->enqueue($flag_single_js_file);
    }

    $queue->end();

    my @threads;
    while (my $url = $queue->dequeue_nb()) {
        push @threads, threads->create(\&extract, $url, $flag_output_file);
    }

    $_->join() for @threads;

    my $elapsed_time = time() - $start_time;
    printf("Process took %d ms\n", $elapsed_time * 1000);
}

main();
