The way we detect the terminal's encoding is to examine this ratio:

<ul><ul><b>number of bytes sent : number of spaces the cursor moves in response</b></ul></ul>

## Cursor movement

There are four ways a character can move the cursor:

* the cursor moves one space right
<ul><ul>These characters are sooo common, we're almost completely uninterested in them.</ul></ul>
* the cursor doesn't move
<ul><ul>These tend to be control characters[1], or combining characters[2]. They could also be surrogate characters [3], but those aren't supposed occur in interchange.</ul></ul>
* the cursor moves two spaces right
<ul><ul>These are "FullWidth" Asian characters [4]</ul></ul>
* the cursor moves vertically [5]

## Number of bytes per character

(note: [here is a list](http://w3techs.com/technologies/overview/character_encoding/all) of the most popular encodings)

The number of bytes varies by encoding:

<table>
<tr><th>encoding  <th>encoded bytes

<tr><td>adobeStdenc <td>1
<tr><td>AdobeSymbol <td>1
<tr><td>AdobeZdingbat <td>1
<tr><td>ascii <td>1
<tr><td>cp37 <td>1
<tr><td>cp424 <td>1
<tr><td>cp437 <td>1
<tr><td>cp500 <td>1
<tr><td>cp737 <td>1
<tr><td>cp775 <td>1
<tr><td>cp850 <td>1
<tr><td>cp852 <td>1
<tr><td>cp855 <td>1
<tr><td>cp856 <td>1
<tr><td>cp857 <td>1
<tr><td>cp858 <td>1
<tr><td>cp860 <td>1
<tr><td>cp861 <td>1
<tr><td>cp862 <td>1
<tr><td>cp863 <td>1
<tr><td>cp864 <td>1
<tr><td>cp865 <td>1
<tr><td>cp866 <td>1
<tr><td>cp869 <td>1
<tr><td>cp874 <td>1
<tr><td>cp875 <td>1
<tr><td>cp1006 <td>1
<tr><td>cp1026 <td>1
<tr><td>cp1047 <td>1
<tr><td>cp1250 <td>1
<tr><td>cp1251 <td>1
<tr><td>cp1252 <td>1
<tr><td>cp1253 <td>1
<tr><td>cp1254 <td>1
<tr><td>cp1255 <td>1
<tr><td>cp1256 <td>1
<tr><td>cp1257 <td>1
<tr><td>cp1258 <td>1
<tr><td>dingbats <td>1
<tr><td>hp-roman8 <td>1
<tr><td>iso-8859-1 <td>1
<tr><td>iso-8859-2 <td>1
<tr><td>iso-8859-3 <td>1
<tr><td>iso-8859-4 <td>1
<tr><td>iso-8859-5 <td>1
<tr><td>iso-8859-6 <td>1
<tr><td>iso-8859-7 <td>1
<tr><td>iso-8859-8 <td>1
<tr><td>iso-8859-9 <td>1
<tr><td>iso-8859-10 <td>1
<tr><td>iso-8859-11 <td>1
<tr><td>iso-8859-13 <td>1
<tr><td>iso-8859-14 <td>1
<tr><td>iso-8859-15 <td>1
<tr><td>iso-8859-16 <td>1
<tr><td>jis0201 <td>1
<tr><td>koi8-f <td>1
<tr><td>koi8-r <td>1
<tr><td>koi8-u <td>1
<tr><td>MacArabic <td>1
<tr><td>MacCentralEurRoman <td>1
<tr><td>MacCroatian <td>1
<tr><td>MacCyrillic <td>1
<tr><td>MacDingbats <td>1
<tr><td>MacFarsi <td>1
<tr><td>MacGreek <td>1
<tr><td>MacHebrew <td>1
<tr><td>macIceland <td>1
<tr><td>MacRoman <td>1
<tr><td>MacRomanian <td>1
<tr><td>MacRumanian <td>1
<tr><td>MacSami <td>1
<tr><td>MacSymbol <td>1
<tr><td>MacThai <td>1
<tr><td>MacTurkish <td>1
<tr><td>MacUkrainian <td>1
<tr><td>nextstep <td>1
<tr><td>posix-bc <td>1
<tr><td>symbol <td>1
<tr><td>viscii <td>1

<tr><td colspan=2><br><br>

<tr><td>gb2312-raw <td>2
<tr><td>gb12345-raw <td>2
<tr><td>iso-ir-165 <td>2
<tr><td>jis0208 <td>2
<tr><td>jis0212 <td>2
<tr><td>ksc5601-raw <td>2

<tr><td colspan=2><br><br>

<tr><td>big5-eten <td>1 - 2
<tr><td>big5-hkscs <td>1 - 2
<tr><td>cp932 <td>1 - 2
<tr><td>cp936 <td>1 - 2
<tr><td>cp949 <td>1 - 2
<tr><td>cp950 <td>1 - 2
<tr><td>euc-cn <td>1 - 2
<tr><td>euc-kr <td>1 - 2
<tr><td>johab <td>1 - 2
<tr><td>MacChineseSimp <td>1 - 2
<tr><td>macChintrad <td>1 - 2
<tr><td>MacJapanese <td>1 - 2
<tr><td>MacKorean <td>1 - 2
<tr><td>shiftjis <td>1 - 2
<tr><td>euc-jp <td>1 - 3

</table>

(In this section, encoding names are those used by Perl's "Encode" module.  Note that we will probably end up using a different standard for determining an encoding's canonical name)

## Cursor movement — implementation details

During development, we use Perl's [unicode properties](http://perldoc.perl.org/perluniprops.html) to look for characters that have anything other than an X+1 cursor movement.  The specific properties we use are:

<table>
<tr><th>movement    <th>description     <th>property

<tr><td>X + 2       <td>full-width characters [4]   <td><tt>\p{East_Asian_Width: Wide}

<tr><td>Y + 1       <td>various newlines            <td><tt>\p{Line_Break: Break_After}<br>\p{Line_Break: Carriage_Return}<br>\p{Line_Break: Line_Feed}<br>\p{Line_Break: Next_Line}

<tr><td>X + 0       <td>control characters          <td><tt>[\x00-\x1F\x7F-\x9F]

<tr><td>X + 0       <td>combining characters [2]    <td><tt>\p{Line_Break: Combining_Mark}</tt> <br>(note: includes control chars)

<tr><td>X + 0       <td>surrogate characters [3]    <td><tt>\p{Surrogate}

</table>


## References

[1] [Wikipedia, "Unicode control characters"](http://en.wikipedia.org/wiki/Unicode_control_characters#ISO_6429_control_characters_.28C0_and_C1.29)

[2] [Unicode 6.1 standard, section 3.6 "Combination"](http://www.unicode.org/versions/Unicode6.1.0/ch03.pdf#G30602)

[3] [Wikipedia, "UTF-16"](http://en.wikipedia.org/wiki/UTF-16#Code_points_U.2B10000_to_U.2B10FFFF)

&nbsp; &nbsp; also see: [definition of "surrogate pair" at unicode.org](http://www.unicode.org/glossary/#surrogate_pair)

[4] [Unicode Standard Annex #11 "East Asian Width"](http://www.unicode.org/reports/tr11/tr11-14.html)

[5] [Unicode Standard Annex #14 "Unicode Line Breaking Algorithm", Table 1](http://unicode.org/reports/tr14/#Table1), see Mandatory Break, Carriage Return, Line Feed, and Next Line
