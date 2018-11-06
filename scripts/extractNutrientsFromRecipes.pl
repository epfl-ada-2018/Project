#!/usr/bin/perl

######################################################################################################
# This script extracts nutritional info from recipe HTML pages, using hand-crafted regular expressions
######################################################################################################

use Digest::MD5 qw(md5 md5_hex md5_base64);

$PATH = "*********";
$RECIPE_PAGES_PATH = "$PATH/recipePages";
$RECIPE_LIST_FILE = "$PATH/weight_uniqueRecipeUrls.tsv";

sub readFile {
	my $filename = shift;
	open(FILE, $filename) or return ""; 
	my $string = join("", <FILE>);
	# remove the header line from the file content, such that files with only this line result in "":
	$string =~ s/^<!--.*-->\n//;
	close(FILE);
	return $string;
}

sub printOutput {
	my $kcal = shift;
	my $carb = shift;
	my $fat = shift;
	my $prot = shift;
	my $sodium = shift;
	my $chol = shift;
	my $hash = shift;
	my $url = shift;
	print "$kcal\t$carb\t$fat\t$prot\t$sodium\t$chol\t$hash.html\t" . computeDomain($url) . "\t$url\n";
}

sub computeDomain {
	my $url = shift;
	my $domain = $url;
	$domain =~ s|^http://(www.)?||;
	$domain =~ s|/.*$||;
	return $domain;
}

sub normalizeNumber {
	my $num = shift;
	$num =~ s/,//g;
	return $num;
}

sub carbToKcal {
	my $quant = shift;
	my $unit = shift;	# must be 'g' or 'mg'
	my $factor = $unit eq 'mg' ? 0.001 : 1;
	return 4 * normalizeNumber($quant) * $factor;
}

sub fatToKcal {
	my $quant = shift;
	my $unit = shift;	# must be 'g' or 'mg'
	my $factor = $unit eq 'mg' ? 0.001 : 1;
	return 9 * normalizeNumber($quant) * $factor;
}

sub protToKcal {
	my $quant = shift;
	my $unit = shift;	# must be 'g' or 'mg'
	my $factor = $unit eq 'mg' ? 0.001 : 1;
	return 4 * normalizeNumber($quant) * $factor;
}
	
sub toMg {
	my $quant = shift;
	my $unit = shift;	# must be 'g' or 'mg'
	my $factor = $unit eq 'mg' ? 1 : 1000;
	return normalizeNumber($quant) * $factor;
}
	
my @md5 = ();
my @md5_inv = ();

open(REC, $RECIPE_LIST_FILE) or die $!;
while(my $url = <REC>) {
	chomp $url;
	my $hash = md5_hex($url);
	$md5{$url} = $hash;
	$md5_inv{$hash} = $url;
}
close(REC);

my %goodDomains = (
	"allrecipes.com" => 1,
	"food.com" => 1,
	"yummly.com" => 1,
	"myrecipes.com" => 1,
	"recipes.sparkpeople.com" => 1,
	"bettycrocker.com" => 1,
	"foodnetwork.com" => 1,
	"cdkitchen.com" => 1,
	"eatingwell.com" => 1,
	"delish.com" => 1,
	"cookeatshare.com" => 1,
	"recipe.com" => 1,
	"kraftrecipes.com" => 1,
	"epicurious.com" => 1
	);

my $count = 0;

# - means file not found or without valid HTML content
# ? means no match in file
foreach my $url (keys %md5) {
	++$count;
	print STDERR "$count\n" if ($count % 1000 == 0);
	next if (!defined($goodDomains{computeDomain($url)}));
	if ($url =~ m{^http://(www\.)?allrecipes\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<b>Amount Per Serving</b>}
			&& $html =~ m{<span class="calories">([0-9\.,]+)</span>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span class="totalcarbs">([0-9\.,]+)(g|mg)</span>}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<span class="fat">([0-9\.,]+)(g|mg)</span>})  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{<span class="protein">([0-9\.,]+)(g|mg)</span>}) { $prot = protToKcal($1, $2); }
				if ($html =~ m{<span class="sodium">([0-9\.,]+)(g|mg)</span>}) { $sodium = toMg($1, $2); }
				if ($html =~ m{<span class="cholesterol">([0-9\.,]+)(g|mg)</span>}) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?food\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<em>Amount per serving</em>}
			&& $html =~ m{<span itemprop="calories">([0-9\.,]+)</span>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span itemprop="carbohydrateContent">([0-9\.,]+)</span></span></span><span class="type"> (g|mg)</span>}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<span itemprop="fatContent">([0-9\.,]+)</span></span></span><span class="type"> (g|mg)</span>})  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{<span itemprop="proteinContent">([0-9\.,]+)</span></span></span><span class="type"> (g|mg)</span>}) { $prot = protToKcal($1, $2); }
				if ($html =~ m{<span itemprop="sodiumContent">([0-9\.,]+)</span></span><span class="type"> (g|mg)</span>}) { $sodium = toMg($1, $2); }
				if ($html =~ m{<span itemprop="cholesterolContent">([0-9\.,]+)</span></span></span><span class="type"> (g|mg)</span>}) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?yummly\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<div class="amount" colspan="2">Amount Per Serving</div>}
			&& $html =~ m{<span class="calories" itemprop="calories">([0-9\.,]+)</span>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span itemprop="carbohydrateContent">\s*([0-9\.,]+)\s*</span>\s*(g|mg)}s) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<span itemprop="fatContent">\s*([0-9\.,]+)\s*</span>\s*(g|mg)}s)  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{<span itemprop="proteinContent">\s*([0-9\.,]+)\s*</span>\s*(g|mg)}s) { $prot = protToKcal($1, $2); }
				if ($html =~ m{<span itemprop="sodiumContent">\s*([0-9\.,]+)\s*</span>\s*(g|mg)}s) { $sodium = toMg($1, $2); }
				if ($html =~ m{<span itemprop="cholesterolContent">\s*([0-9\.,]+)\s*</span>\s*(g|mg)}s) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?myrecipes\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<strong>Amount per serving</strong>}
			&& $html =~ m/{"type":"calories","unit":"","amount":"([0-9\.,]+)"}/) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m/{"type":"carbohydrate","unit":"(g|mg)","amount":"([0-9\.,]+)"}/) { $carb = carbToKcal($2, $1); }	# reversed argument order
				if ($html =~ m/{"type":"fat","unit":"(g|mg)","amount":"([0-9\.,]+)"}/)  { $fat = fatToKcal($2, $1); }
				if ($html =~ m/{"type":"protein","unit":"(g|mg)","amount":"([0-9\.,]+)"}/) { $prot = protToKcal($2, $1); }
				if ($html =~ m/{"type":"sodium","unit":"(g|mg)","amount":"([0-9\.,]+)"}/) { $sodium = toMg($2, $1); }
				if ($html =~ m/{"type":"cholesterol","unit":"(g|mg)","amount":"([0-9\.,]+)"}/) { $chol = toMg($2, $1); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?recipes\.sparkpeople\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<b>Amount Per Serving<br>|<li class="servings">Amount Per Serving}
			&& $html =~ m{<b>&nbsp;&nbsp;Calories</b></font></td>\s*<td width="56" height="35"><font size="2">([0-9\.,]+)</font></td>|<span itemprop="calories">Calories: ([0-9\.,]+)</span>}s) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1||$2), '?', '?', '?', '?', '?');	# need to disambiguate between brackets in regex
				if ($html =~ m{<b>&nbsp;&nbsp;Total Carbohydrate</b></font></td>\s*<td width="56" height="35"><font size="2">([0-9\.,]+)</font><font size="2">&nbsp;(g|mg)</font></td>|<li>Total Carbs: ([0-9\.,]+) (g|mg)}s) { $carb = carbToKcal(normalizeNumber($1||$3), $2||$4); }
				if ($html =~ m{<b>&nbsp;&nbsp;Total Fat</b></font></td>\s*<td width="56" height="35"><font size="2">([0-9\.,]+)</font><font size="2">&nbsp;(g|mg)</font></td>|<li>Total Fat: <span itemprop="fat">([0-9\.,]+) (g|mg)</span>}s)  { $fat = fatToKcal(normalizeNumber($1||$3), $2 || $4); }
				if ($html =~ m{<b>&nbsp;&nbsp;Protein</b></font></td>\s*<td width="56" height="35"><font size="2">([0-9\.,]+)</font><font size="2">&nbsp;(g|mg)</font></td>|<li>Protein: <span itemprop="protein">([0-9\.,]+) (g|mg)</span>}s) { $prot = protToKcal(normalizeNumber($1||$3), $2 || $4); }
				if ($html =~ m{<b>&nbsp;&nbsp;Sodium</b></font></td>\s*<td width="56" height="35"><font size="2">([0-9\.,]+)</font><font size="2">&nbsp;(g|mg)</font></td>|<li>Sodium: ([0-9\.,]+) (g|mg)}s) { $sodium = toMg(normalizeNumber($1||$3), $2 || $4); }
				if ($html =~ m{<b>&nbsp;&nbsp;Cholesterol</b></font></td>\s*<td width="56" height="35"><font size="2">([0-9\.,]+)</font><font size="2">&nbsp;(g|mg)</font></td>|<li>Cholesterol: <span itemprop="cholesterol">([0-9\.,]+) (g|mg)</span>}s) { $chol = toMg(normalizeNumber($1||$3), $2 || $4); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?bettycrocker\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{1 Serving.*</span>}
			&& $html =~ m{<li itemprop="calories">Calories ([0-9\.,]+)</li>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				# Ol' Betty Crocker needs the special regexation package...
				if ($html =~ m{<li itemprop="carbohydrateContent">Total Carbohydrate ([0-9\.,]+)( (\d)/(\d))?(g|mg)</li>}) { $carb = carbToKcal($1+($4?$3/$4:0), $5); }
				if ($html =~ m{<li itemprop="fatContent">Total Fat ([0-9\.,]+)( (\d)/(\d))?(g|mg)</li>})  { $fat = fatToKcal($1+($4?$3/$4:0), $5); }
				if ($html =~ m{<li itemprop="proteinContent">Protein ([0-9\.,]+)( (\d)/(\d))?(g|mg);?</li>}) { $prot = protToKcal($1+($4?$3/$4:0), $5); }
				if ($html =~ m{<li itemprop="sodiumContent">Sodium ([0-9\.,]+)( (\d)/(\d))?(g|mg);?</li>}) { $sodium = toMg($1+($4?$3/$4:0), $5); }
				if ($html =~ m{<li itemprop="cholesterolContent">Cholesterol ([0-9\.,]+)( (\d)/(\d))?(g|mg);?</li>}) { $chol = toMg($1+($4?$3/$4:0), $5); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?foodnetwork\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<dd>Per Serving</dd>}
			&& $html =~ m{<dt>Calories</dt><dd>([0-9\.,]+)</dd>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<dt>Carbohydrates</dt><dd>([0-9\.,]+) *(g|mg)</dd>}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<dt>(Total )?Fat</dt><dd>([0-9\.,]+) *(g|mg)</dd>})  { $fat = fatToKcal($2, $3); }	# shifted index
				if ($html =~ m{<dt>Protein</dt><dd>([0-9\.,]+) *(g|mg)</dd>}) { $prot = protToKcal($1, $2); }
				if ($html =~ m{<dt>Sodium</dt><dd>([0-9\.,]+) *(g|mg)</dd>}) { $sodium = toMg($1, $2); }
				if ($html =~ m{<dt>Cholesterol</dt><dd>([0-9\.,]+) *(g|mg)</dd>}) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?cdkitchen\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<span itemprop="servingSize">per serving</span>}
			&& $html =~ m{<span itemprop="calories">([0-9\.,]+) calories</span>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span class="carbohydrateContent">([0-9\.,]+) (grams|milligrams) carbohydrates</span>}) { $carb = carbToKcal($1, $2 eq 'grams' ? 'g' : 'mg'); }
				if ($html =~ m{<span class="fatContent">([0-9\.,]+) (grams|milligrams) fat</span>})  { $fat = fatToKcal($1, $2 eq 'grams' ? 'g' : 'mg'); }	# map from abbrev to full
				if ($html =~ m{<span class="proteinContent">([0-9\.,]+) (grams|milligrams) protein</span>}) { $prot = protToKcal($1, $2 eq 'grams' ? 'g' : 'mg'); }
				if ($html =~ m{<td class="type">Sodium \((g|mg)\)</td>\s*<td class="type">([0-9\.,]+)</td>}s) { $sodium = toMg($2, $1); }	# inverted indices
				if ($html =~ m{<td class="type">Cholesterol \((g|mg)\)</td>\s*<td class="type">([0-9\.,]+)</td>}s) { $chol = toMg($2, $1); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?eatingwell\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<p><strong>Per serving:</strong>}
			&& $html =~ m{<span itemprop="calories">\s*([0-9\.,]+)</span>}s) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span itemprop="carbohydrateContent">\s*([0-9\.,]+) (g|mg)</span>}s) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<span itemprop="fatContent">\s*([0-9\.,]+) (g|mg)</span>}s)  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{<span itemprop="proteinContent">\s*([0-9\.,]+) (g|mg)</span>}s) { $prot = protToKcal($1, $2); }
				if ($html =~ m{<span itemprop="sodiumContent">\s*([0-9\.,]+) (g|mg)</span>}s) { $sodium = toMg($1, $2); }
				if ($html =~ m{<span itemprop="cholesterolContent">\s*([0-9\.,]+) (g|mg)}s) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?delish\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<span>\(per serving\)</span>}
			&& $html =~ m{<td align="right" class="calories"><strong>([0-9\.,]+)</strong></td>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<td>Total Carbohydrate</td><td align="right">(<strong>)?(([0-9\.,]+) *(g|mg)|--|0)(</strong>)?</td>}) { $carb = carbToKcal($2 eq '--' ? 0 : $3, $4||'g'); }
				if ($html =~ m{<td>Total Fat</td><td align="right">(<strong>)?(([0-9\.,]+) *(g|mg)|--|0)(</strong>)?</td>})  { $fat = fatToKcal($2 eq '--' ? 0 : $3, $4||'g'); }	# can have '--' instead of '0'
				if ($html =~ m{<td>Protein</td><td align="right">(<strong>)?(([0-9\.,]+) *(g|mg)|--|0)(</strong>)?</td>}) { $prot = protToKcal($2 eq '--' ? 0 : $3, $4||'g'); }
				if ($html =~ m{<td>Sodium</td><td align="right">(<strong>)?(([0-9\.,]+) *(g|mg)|--|0)(</strong>)?</td>}) { $sodium = toMg($2 eq '--' ? 0 : $3, $4||'g'); }
				if ($html =~ m{<td>Cholesterol</td><td align="right">(<strong>)?(([0-9\.,]+) *(g|mg)|--|0)(</strong>)?</td>}) { $chol = toMg($2 eq '--' ? 0 : $3, $4||'g'); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?cookeatshare\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{Amount Per Serving|<div class="servings"><strong>Servings:</strong>\s*<span class='yield'>1\s*</span></div>}
			&& $html =~ m{<span class='value cals'><span class="calories">([0-9\.,]+)</span></span>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span class="carbohydrates">([0-9\.,]+)</span>(g|mg)}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<span class="fat">([0-9\.,]+)</span>(g|mg)})  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{<span class="protein">([0-9\.,]+)</span>(g|mg)}) { $prot = protToKcal($1, $2); }
				if ($html =~ m{<span class='type'>Sodium</span>\s*<span class='value'>([0-9\.,]+)(g|mg)</span>}s) { $sodium = toMg($1, $2); }
				if ($html =~ m{<span class="cholesterol">([0-9\.,]+)</span>(g|mg)}) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?recipe\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{Per serving:}
			&& $html =~ m{Per serving: Calories ([0-9\.,]+)}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{Carbohydrate ([0-9\.,]+) (g|mg)}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{Total Fat ([0-9\.,]+) (g|mg)})  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{Protein ([0-9\.,]+) (g|mg)}) { $prot = protToKcal($1, $2); }
				if ($html =~ m{Sodium ([0-9\.,]+) (g|mg)}) { $sodium = toMg($1, $2); }
				if ($html =~ m{Cholesterol ([0-9\.,]+) (g|mg)}) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?kraftrecipes\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<h4>nutritional info per serving</h4>}
			&& $html =~ m{<span class="calories" property="v:calories">([0-9\.,]+)\s*</span>}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{<span class="carbohydrates" property="v:carbohydrates ">([0-9\.,]+) (g|mg)</span>}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{<span class="fat" property="v:fat">([0-9\.,]+) (g|mg)</span>})  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{<span class="protein" property="v:protein">([0-9\.,]+) (g|mg)</span>}) { $prot = protToKcal($1, $2); }
				if ($html =~ m{Sodium</a>\s*</div>\s*<div class="amount">\s*&nbsp;([0-9\.,]+) (g|mg)}s) { $sodium = toMg($1, $2); }
				if ($html =~ m{<span class="cholesterol" property="v:cholesterol">([0-9\.,]+) (g|mg)</span>}) { $chol = toMg($1, $2); }
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	} elsif ($url =~ m{^http://(www\.)?epicurious\.com}) {
		my $html = readFile("$RECIPE_PAGES_PATH/$md5{$url}.html");
		my ($kcal, $carb, $fat, $prot, $sodium, $chol) = ('', '', '', '', '', '');
		if ($html =~ m{<p>Nutritional analysis per serving}
			&& $html =~ m{: ([0-9\.,]+) calories}) {
				($kcal, $carb, $fat, $prot, $sodium, $chol) = (normalizeNumber($1), '?', '?', '?', '?', '?');
				if ($html =~ m{([0-9\.,]+)\s*(g|mg) (carbohydrate|carbs)}) { $carb = carbToKcal($1, $2); }
				if ($html =~ m{([0-9\.,]+)\s*(g|mg) fat})  { $fat = fatToKcal($1, $2); }
				if ($html =~ m{([0-9\.,]+)\s*(g|mg) protein}) { $prot = protToKcal($1, $2); }
				# no sodium and cholesterol info
		} else {
			my $symbol = $html eq "" ? '-' : '?';
			($kcal, $carb, $fat, $prot, $sodium, $chol) = ($symbol, $symbol, $symbol, $symbol, $symbol, $symbol);
		}
		printOutput($kcal, $carb, $fat, $prot, $sodium, $chol, $md5{$url}, $url);
	}
}