.\" This file is part of groff.
.\"
.\" groff is free software; you can redistribute it and/or modify it
.\" under the terms of the GNU General Public License as published by
.\" the Free Software Foundation, either version 3 of the License, or
.\" (at your option) any later version.
.\"
.\" groff is distributed in the hope that it will be useful, but WITHOUT
.\" ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
.\" or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
.\" License for more details.
.\"
.\" You should have received a copy of the GNU General Public License
.\" along with this program. If not, see <http://www.gnu.org/licenses/>.
.
.\" Handle font requests with families, for instance in tbl(1) tables.
.if n \{\
.  ftr CR B \" for a visible distinction from roman
.  ftr CB B
.  ftr CI I
.  ftr CBI BI
.  \" Redefine CW to use bold instead for a visible font change.
.  als CW B
.  \" The "document control settings" table imposes this minimum width.
.  nr LL 87n
.\}
.\" This document doesn't require the minus sign (in Times) but we do
.\" want a copy- and-pastable hyphen-minus.
.ie '\*[.T]'cp1047' .char \- \N'96'
.el                 .char \- \N'45'
.\" A very limited output device might not have a dagger glyph.
.fchar \[dg] *
.nr PS 11
.nr VS 13
.ds FR 1
.nr TC-MARGIN \w'00' \" expect 2-digit page numbers at most
.ie t .nr PI 3.5n
.el   .nr PI 4n
.ND May 2023
.EH '%''May 2023'
.EF ''''
.OH 'Using \f[I]groff\f[] with the \f[I]ms\f[] macros''%'
.OF ''''
.TL
Using
.BI groff
with the
.BI ms
Macro Package
.AU
Larry Kollar
.AI
kollar@alltel.net
.AU
G.\& Branden Robinson
.AI
g.branden.robinson@gmail.com
.AB no
The
.I ms
(\[lq]manuscript\[rq]) package is suitable for the composition of
letters,
memoranda,
reports,
and books.
.
These
.I groff
macros feature cover page and table of contents generation,
automatically numbered headings,
several paragraph styles,
a variety of text styling options,
footnotes,
and multi-column page layouts.
.
.I ms
supports the
.I tbl ,
.I eqn ,
.I pic ,
and
.I refer
preprocessors for inclusion of tables,
mathematical equations,
diagrams,
and standardized bibliographic citations.
.
This implementation is mostly compatible with the documented interface
and behavior of AT&T Unix Version\~7
.I ms .
.
Many extensions from 4.2BSD (Berkeley)
.\" Few changes were made in 4.3, Tahoe, Reno, or 4.4.
and Tenth Edition Research Unix have been recreated.
.AE
.
.
.\" ------------------------- End of cover page ------------------------
.NH 1
Introduction
.XS
Introduction
.XE
.
.
.LP
The
.I ms
macros are the oldest surviving package for
.I roff
systems.\**
.
.FS
While manual
.I pages
are older,
early ones used macros supplanted by the
.I man
package of Seventh Edition Unix (1979).
.
.I ms
shipped with Sixth Edition (1975) and was documented by Mike Lesk in a
Bell Labs internal memorandum.
.FE
.
While the
.I man
package was designed for brief reference documents,
the
.I ms
macros are also suitable for longer works intended for printing and
possible publication.
.
.
.PP
In this document,
a right arrow (\[->]) is used to indicate a tab character in the input.
.
.
.KS
.NH 2
Basic information
.XS
	Basic information
.XE
.
.
.LP
.I ms
documents are plain text files;
prepare them with your preferred text editor.
.
If you're in a hurry to start,
know that
.I ms
needs one of its macros called at the beginning of a document so that it
can initialize.
.
A
.I macro
is a formatting instruction to
.I ms.
.
Put a macro call on a line by itself.
.
Use
.CW .PP
if you want your paragraph's first line to be indented,
or
.CW .LP
if you don't.
.KE
.
.
.PP
After that,
start typing normally.
.
It is a good practice to start each sentence on a new line,
or to put two spaces after sentence-ending punctuation,
so that the formatter knows where the sentence boundaries are.
.
You can separate paragraphs with further paragraphing macro calls,
or with blank lines,
and you can indent with tabs.
.
When you need one of the features mentioned earlier,
return to this manual.
.
.
.PP
Format the document with the
.I groff (1)
command.
.
.I nroff (1)
can be useful for previewing.
.
.
.if n .ftr TI I
.TS
box center;
Lf(CR)1 Lf(CB).
$	editor radical.ms \f[TI]# vim, emacs, .\|.\|.
$	nroff -ww -z -ms radical.ms \f[TI]# check for errors
$	nroff \-ms radical.ms | less \-R
$	groff \-T pdf \-ms radical.ms > radical.pdf
$	see radical.pdf \f[TI]# or your favorite PDF viewer
.TE
.if n .ftr TI
.
.
.PP
Our
.CW radical.ms
document might look like this.
.
.
.TS
box center;
Lf(CR).
\&.LP
Radical novelties are so disturbing that they tend to be
suppressed or ignored, to the extent that even the
possibility of their existence in general is more often
denied than admitted.
.sp
\[->]That\[aq]s what Dijkstra said, anyway.
.TE
.
.
.LP
.I ms
exposes many aspects of document layout to user control via
.I groff 's
.I registers
and
.I strings,
which store numbers and text,
respectively.
.
Measurements in
.I groff
are expressed with a suffix called a
.I "scaling unit."
.
.
.TS
box center;
cb cb
cf(CR) l .
Scaling unit	Description
_
i	inches (\[sd])
c	centimeters
p	points (1/72\[sd])
P	picas (1/6\[sd])
v	\[lq]vees\[rq]; current vertical spacing
m	\[lq]ems\[rq]; width of an \[lq]M\[rq] in the current font
n	\[lq]ens\[rq]; one-half em
.TE
.
.
.PP
Set registers with the
.CW nr
request
and strings with the
.CW ds
request.
.
.I Requests
are like macro calls;
they go on lines by themselves and start with the
.I "control character,"
a dot
.CW . ). (
.
The difference is that they directly instruct the formatter program,
rather than the macro package.
.
We'll discuss a few as applicable.
.
It is wise to specify a scaling unit when setting any register that
represents a length,
size,
or distance.
.
.
.TS
box center;
lf(CR).
\&.nr PS 10.5p \[rs]" Use 10.5\-point type.
\&.ds FAM P    \[rs]" Use Palatino font family.
.TE
.
.
.LP
In the foregoing,
we see that
.CW \[rs]"
begins a comment.
.
This is an example of an
.I "escape sequence,"
the other kind of formatting instruction.
.
Escape sequences can appear anywhere.
.
They begin with the escape character
.CW \[rs] ) (
and are followed by at least one more character.
.
.I ms
documents like this one tend to use only a few of
.I groff 's
many requests and escape sequences;
see the
.I groff (7)
man page for complete lists.
.
.
.TS
box center;
Cb Cb
Lf(CR) Lx .
Escape sequence	Description
_
\[rs]"	Begin comment; ignore remainder of line.
\[rs]n[\f[I]reg\f[]]	T{
Interpolate value of register
.I reg .
T}
\[rs]*[\f[I]str\f[]]	T{
Interpolate contents of string
.I str .
T}
\[rs]*\f[I]s	T{
abbreviation of
.CW \[rs]*[\f[I]s\f[]] ;
the name
.I s
must be only one character
T}
\[rs][\f[I]char\f[]]	T{
Interpolate glyph of special character named
.I char .
T}
\[rs]&	non-printing, zero-width dummy character
\[rs]\[ti]	T{
Insert an unbreakable space of adjustable width like a normal space.
T}
\[rs]|	T{
Move horizontally by one-sixth em
(\[lq]thin space\[rq]).
T}
.TE
.
.
.PP
Prefix any words that start with a dot
.CW .\& ) (
or neutral apostrophe
.CW \[aq] ) (
with
.CW \[rs]&
if they are at the beginning of an input line
(or might become that way in editing)
to prevent them from being interpreted as macro calls or requests.
.
Suffix
.CW . ,
.CW ? ,
and
.CW !\&
with
.CW \[rs]&
when needed to cancel end-of-sentence detection.
.
.
.TS
box center;
lf(CR).
My exposure was \[rs]&.5 to \[rs]&.6 Sv of neutrons, said Dr.\[rs]&
Wallace after the criticality incident.
.TE
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
General structure of an
.BI ms
document
.XS
General structure of an
.I ms
document
.XE
.
.
.LP
The
.I ms
macro package expects a certain amount of structure:
a well-formed document contains at least one paragraphing or heading
macro call.
.
Longer documents have a structure as follows.
.
.
.IP "\fBDocument type\fP"
Calling the
.CW RP
macro at the beginning of your document puts the document description
(see below)
on a cover page.
.
Otherwise,
.I ms
places this information
(if any)
on the first page,
followed immediately by the body text.
.
Some document types found in other
.I ms
implementations are specific to AT&T or Berkeley,
and are not supported by
.I "groff ms" .
.
.
.IP "\fBFormat and layout\fP"
By setting registers and strings,
you can configure your document's typeface,
margins,
spacing,
headers and footers,
and footnote arrangement.
.
See section \[lq]Document control settings\[rq] below.
.
.
.IP "\fBDocument description\fP"
A document description consists of any of:
a title,
one or more authors' names and affiliated institutions,
an abstract,
and a date or other identifier.
.
See section \[lq]Document description macros\[rq] below.
.
.
.IP "\fBBody text\fP"
The main matter of your document follows its description
(if any).
.
.I ms
supports highly structured text consisting of paragraphs interspersed
with multi-level headings
(chapters,
sections,
subsections,
and so forth)
and augmented by lists,
footnotes,
tables,
diagrams,
and similar material.
.
See section \[lq]Body text\[rq] below.
.
.
.IP "\fBTables of contents\fP"
Macros enable the collection of entries for a table of contents
(or index)
as the material they discuss appears in the document.
.
You then call a macro to emit the table of contents at the end of
your document.
.
The table of contents must necessarily follow the rest of the text since
GNU
.I troff
is a single-pass formatter;
it thus cannot determine the page number of a division of the text until
it has been set and output.
.
Since
.I ms
output was designed for the production of hard copy,
the traditional procedure was to manually relocate the pages containing
the table of contents between the cover page and the body text.
.
Today,
page resequencing is more often done in the digital domain.
.
An index works similarly,
but because it typically needs to be sorted after collection,
its preparation requires separate processing.
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Document control settings
.XS
Document control settings
.XE
.
.
.LP
The document parameters below are presented in the syntax
used to interpolate their values.
.
For any unsatisfactory default,
define its register,
string,
or special character before calling any
.I ms
macro other than
.CW RP .
.
The \[lq]Next\[rq] heading indicates that changes to the parameter are
effective as of the next new element processed of the listed type.
.
For entries marked
.I special ,
see the discussion in the applicable section.
.
.
.TS H
box;
cb | cb cb cb cb
l | lf(CR)p-1 lx l lf(CR)p-1.
Type	Parameter	Definition	Next	Default
_
.TH
Margins	\[rs]n[PO]	Page offset (left margin)	page\
	1i (0)\*{*\*}
\^	\[rs]n[LL]	Line length	paragraph	\
6.5i (65n)\*{*\*}
\^	\[rs]n[LT]	Title line length	paragraph	\
6.5i (65n)\*{*\*}
\^	\[rs]n[HM]	Top (header) margin	page	1i
\^	\[rs]n[FM]	Bottom (footer) margin	page	1i
_
T{
Titles
.br
(headers,
.br
footers)
T}	\[rs]*[LH]	Left header text	header	\f[I]empty
\^	\[rs]*[CH]	Center header text	header	\-\[rs]n[%]\-
\^	\[rs]*[RH]	Right header text	header	\f[I]empty
\^	\[rs]*[LF]	Left footer text	footer	\f[I]empty
\^	\[rs]*[CF]	Center footer text	footer	\f[I]empty
\^	\[rs]*[RF]	Right footer text	footer	\f[I]empty
_
Text	\[rs]n[PS]	Type (point) size	paragraph	10p
\^	\[rs]n[VS]	Vertical spacing	paragraph	12p
\^	\[rs]n[HY]	Hyphenation mode	paragraph	6
\^	\[rs]*[FAM]	Font family	paragraph	T
_
Paragraphs	\[rs]n[PI]	Indentation	paragraph	5n
\^	\[rs]n[PD]	Paragraph distance (spacing)	paragraph\
	0.3v \f[R](\f[]1v\f[R])\*{\[dg]\*}
\^	\[rs]n[QI]	Quotation indentation	paragraph	5n
\^	\[rs]n[PORPHANS]	# of initial lines kept	paragraph\
	1
_
Headings	\[rs]n[PSINCR]	Type (point) size increment\
	heading	1p
\^	\[rs]n[GROWPS]	Size increase depth limit	heading	0
\^	\[rs]n[HORPHANS]	# of following lines kept\
	heading	1
\^	\[rs]*[SN\-STYLE]	Numbering style (alias)	heading\
	\[rs]*[SN\-DOT]
_
Footnotes	\[rs]n[FI]	Indentation	footnote	2n
\^	\[rs]n[FF]	Format	footnote	0
\^	\[rs]n[FPS]	Type (point) size	footnote\
	\[rs]n[PS]\-2p
\^	\[rs]n[FVS]	Vertical spacing	footnote\
	\[rs]n[FPS]+2p
\^	\[rs]n[FPD]	Paragraph distance (spacing)	footnote\
	\[rs]n[PD]/2
\^	\[rs]*[FR]	Line length ratio	\f[I]special	11/12
_
Displays	\[rs]n[DD]	Display distance (spacing)\
	\f[I]special	0.5v \f[R](\f[]1v\f[R])\*{\[dg]\*}
\^	\[rs]n[DI]	Display indentation	\f[I]special	0.5i
_
Other	\[rs]n[MINGW]	Minimum gutter width	page	2n
\^	\[rs]n[TC\-MARGIN]	TOC page number margin width\
	\f[CR]PX\f[] call	\[rs]w\[aq]000\[aq]
\^	\[rs][TC\-LEADER]	TOC leader character\
	\f[CR]PX\f[] call	.\[rs]h\[aq]1m\[aq]
.TE
.
.
.IP \*{*\*}
Defaults vary by output device and paper format;
the values shown are for typesetters using U.S.\& letter paper,
and then terminals.
.
See section \[lq]Paper format\[rq] of the
.I groff (1)
man page.
.
.
.IP \*{\[dg]\*}
The
.CW PD
and
.CW DD
registers use the larger value if the vertical motion quantum of the
output device is too coarse for the smaller one;
usually,
this is the case only for output to terminals and emulators thereof.
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Document description macros
.XS
Document description macros
.XE
.
.
.LP
Only the simplest document lacks a title.\**
.
.FS
Distinguish a document title from \[lq]titles\[rq],
which are what
.I roff
systems call headers and footers collectively.
.FE
.
As its level of sophistication
(or complexity)
increases,
it tends to acquire a date of revision,
explicitly identified authors,
sponsoring institutions for authors,
and,
at the rarefied heights,
an abstract of its content.
.
By default,
.I ms
arranges most of the document description
(the title,
author names and institutions,
and abstract,
but not the date)
at the top of the first page.
.
.
.PP
Define these data by calling the macros below in the order shown;
.CW .DA
or
.CW .ND
can be called to set the document date
(or other identifier)
at any time before (a) the abstract,
if present,
or (b) its information is required in a header or footer.
.
Use of these macros is optional,
except that
.CW .TL
is mandatory if any of
.CW .RP ,
.CW .AU ,
.CW .AI ,
or
.CW .AB
is called,
and
.CW .AE
is mandatory if
.CW .AB
is called.
.
.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.RP \f[R][\f[I]option\f[] .\|.\|.]	T{
Use the \[lq]report\[rq]
(AT&T: \[lq]released paper\[rq])
format for your document,
creating a separate cover page.
.
If the optional
.CW no\-\:\%repeat\-\:\%info
argument is given,
.I ms
produces a cover page but does not repeat any of its information
subsequently
(but see the
.CW DA
macro below regarding the date).
.
Normally,
.CW .RP
sets the page number following the cover page to\~1.
.
Specifying the optional
.CW no\-\:\%renumber
argument suppresses this alteration.
.
Optional arguments can occur in any order.
.
.CW no
is recognized as a synonym of
.CW no\-\:\%repeat\-\:\%info
for AT&T compatibility.
T}
_
\&.TL	T{
Specify the document title.
.
.I ms
collects text on input lines following this call into the title
until reaching
.CW .AU ,
.CW .AB ,
or a heading or paragraphing macro call.
T}
_
\&.AU	T{
Specify an author's name.
.
.I ms
collects text on input lines following this call into the author's name
until reaching
.CW .AI ,
.CW .AB ,
another
.CW .AU ,
or a heading or paragraphing macro call.
.
Call it repeatedly to specify multiple authors.
T}
_
\&.AI	T{
Specify the preceding author's institution.
.
An
.CW .AU
call is usefully followed by at most one
.CW .AI
call;
if there are more,
the last
.CW .AI
call controls.
.
.I ms
collects text on input lines following this call into the author's
institution until reaching
.CW .AU ,
.CW .AB ,
or a heading or paragraphing macro call.
T}
_
\&.DA \f[R][\f[I]x\f[] .\|.\|.\&]	T{
Typeset the current date,
or any
.I x , arguments\~
in the center footer,
and,
if
.CW .RP
is also called,
left-aligned at the end of the document description on the cover page.
T}
_
\&.ND \f[R][\f[I]x\f[] .\|.\|.\&]	T{
Typeset the current date,
or any
.I x , arguments\~
if
.CW .RP
is also called,
left-aligned at the end of the document description on the cover page.
.
This is
.I "groff ms" 's
default.
T}
_
\&.AB \f[R][\f[]no\f[R]]	T{
Begin the abstract.
.
.I ms
collects text on input lines following this call into the abstract
until reaching an
.CW .AE
call.
.
By default,
.I ms
places the word \[lq]ABSTRACT\[rq] centered and in italics above the
text of the abstract.
.
The optional argument
.CW no
suppresses this heading.
T}
_
\&.AE	End the abstract.
.TE
.
.
.KS
.LP
An example document description,
using a cover page,
follows.
.
.
.\" Wrap lines in the code example below at 64 columns.
.TS
box center;
l.
T{
.nf
.CW
\&.RP
\&.TL
The Inevitability of Code Bloat in Commercial and Free Software
\&.AU
J.\[rs]& Random Luser
\&.AI
University of West Bumblefuzz
\&.AB
This report examines the long-term growth of the code bases in
two large,
popular software packages;
the free Emacs and the commercial Microsoft Word.
While differences appear in the type or order of features added,
due to the different methodologies used,
the results are the same in the end.
\&.PP
The free software approach is shown to be superior in that while
free software can become as bloated as commercial offerings,
free software tends to have fewer serious bugs and the added
features are more in line with user demand.
\&.AE
.R
\&.\|.\|.\|the rest of the paper\|.\|.\|.
.fi
T}
.TE
.KE
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Body text
.XS
Body text
.XE
.
.
.LP
A variety of macros,
registers,
and strings can be used to structure and style the body of your
document.
.
They organize your text into
paragraphs,
headings,
footnotes,
and inclusions of material such as tables and figures.
.
.
.KS
.NH 2
Text settings
.XS
	Text settings
.XE
.
.
.LP
The
.CW FAM
string,
a GNU extension,
sets the font family for body text;
the default is
.CW T \[rq]. \[lq]
.
The
.CW PS
and
.CW VS
registers set the type size and vertical spacing
(distance between text baselines),
respectively.
.
The font family and type size are ignored on terminal devices.
.
Setting these parameters before the first call of a heading,
paragraphing,
or (non-date) document description macro also applies them to headers,
footers,
and
(for
.CW FAM )
footnotes.
.
.
.PP
Which font families are available depends on the output device;
as a convention,
.CW T
selects a serif family (\[lq]Times\[rq]),
.CW H
a sans-serif family (\[lq]Helvetica\[rq]),
and
.CW C
a monospaced family (\[lq]Courier\[rq]).
.
The man page for the output driver documents its font repertoire.
.
Consult the
.I groff (1)
man page for lists of available output devices and their drivers.
.
.
.PP
The
.CW HY
register defines the automatic hyphenation mode used with the
.CW hy
request.
.
Setting
.CW \[rs]n[HY]
.CW 0 "" to\~
is equivalent to using the
.CW nh
request.
.
This is a Tenth Edition Research Unix extension.
.KE
.
.
.KS
.NH 2
Typographical symbols
.XS
	Typographical symbols
.XE
.
.
.LP
.I ms
provides a few strings to obtain typographical symbols not easily
entered with the keyboard.
.
These and many others are available as special character escape
sequences\*[-]see
the
.I groff_char (7)
man page.
.
.TS
box center;
cb lb
Lf(CR) Lx.
String	Description
_
\[rs]*[\-]	Interpolate an em dash.
_
\[rs]*[Q]	T{
Interpolate typographer's quotation marks where available,
and neutral double quotes otherwise.
.
.CW \[rs]*[Q]
is the left quote and
.CW \[rs]*[U]
the right.
T}
\[rs]*[U]	\^
.TE
.KE
.
.
.KS
.NH 2
Paragraphs
.XS
	Paragraphs
.XE
.
.
.LP
Paragraphing macros
.I break ,
or terminate,
any pending output line so that a new paragraph can begin.
.
Several paragraph types are available,
differing in how indentation
applies to them:
to left,
right,
or both margins;
to the first output line of the paragraph,
all output lines,
or all but the first.
.
All paragraphing macro calls cause the insertion of vertical space in
the amount stored in the
.CW PD
register,
except at page or column breaks.
.
Alternatively,
a blank input line breaks the output line and vertically spaces by one
vee.
.KE
.
.
.PP
The
.CW PORPHANS
register defines the minimum number of initial lines of any paragraph
that must be kept together to avoid isolated lines at the bottom of a
page.
.
If a new paragraph is started close to the bottom of a page,
and there is insufficient space to accommodate
.CW \[rs]n[PORPHANS]
lines before an automatic page break,
then a page break is forced before the start of the paragraph.
.
This is a GNU extension.
.
.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.LP	Set a paragraph without any (additional) indentation.
_
\&.PP	T{
Set a paragraph with a first-line left indentation of
.CW \[rs]n[PI] .
T}
_
\&.IP \f[R][\f[I]marker\f[] [\f[I]width\f[]]]	T{
Set a paragraph with a left indentation.
.
The optional
.I marker
is not indented and is empty by default.
.
It has several applications;
see subsection \[lq]Lists\[rq] below.
.
.I width
overrides the indentation amount in
.CW \[rs]n[PI] ;
its default unit is
.CW n \[rq]. \[lq]
.
Once specified,
.I width
applies to further
.CW .IP
calls until specified again or a heading or different paragraphing macro
is called.
T}
_
\&.QP	T{
Set a paragraph indented from both left and right margins by
.CW \[rs]n[QI] .
T}
_
T{
\&.QS
.br
\&.QE
T}	T{
Begin
.CW QS ) (
and end
.CW QE ) (
a region where each paragraph is indented from both margins by
.CW \[rs]n[QI] .
.
The text between
.CW .QS
and
.CW .QE
can be structured further by use of other paragraphing macros.
T}
_
\&.XP	T{
Set an \[lq]exdented\[rq] paragraph\[em]one with a left indentation of
.CW \[rs]n[PI]
on every line
.I except
the first
(also known as a hanging indent).
.
This is a Berkeley extension.
T}
.TE
.
.
.KS
.PP
The following example illustrates the use of paragraphing macros.
.
.
.TS
box center;
l.
T{
.nf
.CW
\&.NH 2
Cases used in the 2001 study
\&.LP
Two software releases were considered for this report.
\&.PP
The first is commercial software;
the second is free.
\&.IP \[rs][bu]
Microsoft Word for Windows,
starting with version 1.0 through the current version
(Word 2000).
\&.IP \[rs][bu]
GNU Emacs,
from its first appearance as a standalone editor through the
current version (v20).
See [Bloggs 2002] for details.
\&.QP
Franklin\[aq]s Law applied to software:
software expands to outgrow both RAM and disk space over time.
\&.SH
Bibliography
\&.XP
Bloggs, Joseph R.,
\&.I "Everyone\[aq]s a Critic" ,
Underground Press, March 2002.
A definitive work that answers all questions and criticisms
about the quality and usability of free software.
.R
.fi
T}
.TE
.KE
.
.
.KS
.NH 2
Headings
.XS
	Headings
.XE
.
.
.LP
Use headings to create a hierarchical structure for your document.
.
The
.I ms
macros print headings in
.B bold
using the same font family and,
by default,
type size as the body text.
.
Headings are available with and without automatic numbering.
.
Text on input lines following the macro call becomes the heading's
title.
.
Call a paragraphing macro to end the heading text and start the
section's content.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.NH [\f[I]depth\f[]]	T{
Set an automatically numbered heading.
.
.I ms
produces a numbered heading in the form
.CW
.I a .\c
.I b .\c
.R
.I c .\|.\|.,
to any level desired,
with the numbering of each depth increasing automatically and being
reset to zero when a more significant depth increases.
.
\[lq]1\[rq]\~is the most significant or coarsest division of the
document.
.
Only non-zero values are output.
.
If
.I depth
is omitted,
it is taken to be
.CW 1 .
.
If you specify
.I depth
such that an ascending gap occurs relative to the previous
.CW NH
call\[em]that is,
you \[lq]skip a depth\[rq],
as by
.CW ".NH\~1" \[rq] \[lq]
and then
.CW ".NH\~3" \[rq]\c \[lq]
.I "groff ms" "" \[em]
emits a warning on the standard error stream.
T}
\&.NH S \f[I]heading-depth-index\f[]\f[R] .\|.\|.\f[]	T{
Alternatively,
you can give
.CW NH
a first argument
.CW S , of\~
followed by integers to number the heading depths explicitly.
.
Further automatic numbering,
if used,
resumes using the specified indices as their predecessors.
.
.\" Although undocumented in Tuthill's 4.2BSD ms.diffs paper...
This feature is a Berkeley extension.
T}
.TE
.KE
.
.
.PP
An example may be illustrative.
.
.
.TS
box center;
cb | cb
lf(CR) | lB.
Input	Result
_
T{
.nf
\&.NH 1
Animalia
\&.NH 2
Arthropoda
\&.NH 3
Crustacea
\&.NH 2
Chordata
\&.NH S 6 6 6
Daimonia
\&.NH 1
Plantae
.fi
T}	T{
.nf
1.  Animalia
.sp
1.1.  Arthropoda
.sp
1.1.1.  Crustacea
.sp
1.2.  Chordata
.sp
6.6.6.  Daimonia
.sp
7.  Plantae
.fi
T}
.TE
.
.
.PP
After
.CW .NH
is called,
the assigned number is made available in the strings
.CW SN\-DOT
(as it appears in a printed heading with default formatting,
followed by a terminating period)
and
.CW SN\-NO\-DOT
(with the terminating period omitted).
.
These are GNU extensions.
.
.
.PP
You can control the style used to print numbered headings by defining an
appropriate alias for the string
.CW SN\-STYLE .
.
By default,
.CW \[rs]*[SN\-STYLE]
is aliased to
.CW \[rs]*[SN\-DOT] .
.
If you prefer to omit the terminating period from numbers appearing in
numbered headings,
you may define the alias as follows.
.
.
.TS
box center;
lf(CR).
\&.als SN\-STYLE SN\-NO\-DOT
.TE
.
.
.LP
Any such change in numbering style becomes effective from the next use
of
.CW .NH
following redefinition of the alias for
.CW \[rs]*[SN\-STYLE] .
.
The formatted number of the current heading is available in
.CW \[rs]*[SN]
(a feature first documented by Berkeley),
which facilitates its inclusion in,
for example,
table captions,
equation labels,
and
.CW .XS /\c
.CW .XA /\c
.CW .XE
table of contents entries.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.SH [\f[I]depth\f[]]	T{
Set an unnumbered heading.
.
The optional
.I depth
argument is a GNU extension indicating the heading depth corresponding
to the
.I depth
argument of
.CW .NH .
.
It matches the type size at which the heading is set to that of a
numbered heading at the same depth when the
.CW \[rs]n[GROWPS]
and
.CW \[rs]n[PSINCR]
heading size adjustment mechanism is in effect.
T}
.TE
.
.
.PP
The
.CW PSINCR
register defines an increment in type size to be applied to a heading at
a lesser depth than that specified in
.CW \[rs]n[GROWPS] .
.
The value of
.CW \[rs]n[PSINCR]
should be specified in points with the
.CW p
scaling unit and may include a fractional component;
for example,
.
.
.TS
box center;
lf(CR).
\&.nr PSINCR 1.5p
.TE
.
.
.LP
sets a type size increment of 1.5 points.
.
.
.PP
The
.CW GROWPS
register defines the heading depth above which the type size increment
set by
.CW \[rs]n[PSINCR]
becomes effective.
.
For each heading depth less than the value of
.CW \[rs]n[GROWPS] ,
the type size is increased by
.CW \[rs]n[PSINCR] .
.
Setting
.CW \[rs]n[GROWPS]
to a value less than\~2 disables the incremental heading size feature.
.
.
.PP
In other words,
if the value of
.CW GROWPS
register is greater than the
.I depth
argument to a
.CW .NH
or
.CW .SH
call,
the type size of a heading produced by these macros increases by
.CW \[rs]n[PSINCR]
units over
.CW \[rs]n[PS]
multiplied by the difference of
.CW \[rs]n[GROWPS]
and
.I depth .
.
.
For example,
the sequence
.
.TS
box center;
lf(CR).
\&.nr PS 10
\&.nr GROWPS 3
\&.nr PSINCR 1.5p
\&.NH 1
Carnivora
\&.NH 2
Felinae
\&.NH 3
Felis catus
\&.SH 2
Machairodontinae
.TE
.
.
.LP
will cause \[lq]1. Carnivora\[rq] to be printed in 13-point text,
followed by \[lq]1.1. Felinae\[rq] in 11.5-point text,
while \[lq]1.1.1. Felis catus\[rq] and all more deeply nested headings
will remain in the 10-point text specified by the
.CW PS
register.
.
\[lq]Machairodontinae\[rq] is printed at 11.5 points,
since it corresponds to heading depth\~2.
.
.
.PP
The
.CW \[rs]n[HORPHANS]
register operates in conjunction with the
.CW NH
and
.CW SH
macros to inhibit the printing of isolated headings at the bottom of a
page;
it specifies the minimum number of lines of the subsequent paragraph
that must be kept on the same page as the heading.
.
If insufficient space remains on the current page to accommodate the
heading and this number of lines of paragraph text,
a page break is forced before the heading is printed.
.
Any display macro call or
.I tbl ,
.I pic ,
or
.I eqn
region
(see subsequent sections)
between the heading and the subsequent paragraph suppresses this
grouping.
.
.
.\" The next table is huge and we need a lot of room for it, but we
.\" can't use a keep because it's a boxed repeated-heading table.  Flush
.\" the pending output line and demand half a page.
.br
.ne (\n[.p]u / 2u)
.NH 2
Typeface and decoration
.XS
	Typeface and decoration
.XE
.
.
.LP
The
.I ms
macros provide a variety of ways to style text.
.
Attend closely to the ordering of arguments labeled
.I pre
and
.I post,
which is not intuitive.
.
Support for
.I pre
arguments is a GNU extension.\**
.FS
This idiosyncrasy arose through feature accretion;
for example,
the
.CW B
macro in Version\~6 Unix
.I ms
(1975) accepted only one argument,
the text to be set in boldface.
.
By Version\~7 (1979) it recognized a second argument;
in 1990,
.I "groff ms"
added a \*[Q]pre\*[U] argument,
placing it third to avoid breaking support for older documents.
.FE
.
.
.TS H
box;
lb lb
lf(CR) lx.
Macro	Description
_
.TH
\&.B \f[R][\f[I]text\f[] [\f[I]post\f[] [\f[I]pre\f[]]]]	T{
Style
.I text
in
.B bold ,
followed by
.I post
in the previous font style without intervening space,
and preceded by
.I pre
similarly.
.
Without arguments,
.I ms
styles subsequent text in bold
until the next
paragraphing,
heading,
or no-argument typeface macro call.
T}
_
\&.R \f[R][\f[I]text\f[] [\f[I]post\f[] [\f[I]pre\f[]]]]	T{
As
.CW .B ,
but use the roman style
(upright text of normal weight)
instead of bold.
.
Argument recognition is a GNU extension.
T}
_
\&.I \f[R][\f[I]text\f[] [\f[I]post\f[] [\f[I]pre\f[]]]]	T{
As
.CW .B ,
but use an
.I italic
or oblique style instead of bold.
T}
_
\&.BI \f[R][\f[I]text\f[] [\f[I]post\f[] [\f[I]pre\f[]]]]	T{
As
.CW .B ,
but use a
.BI "bold italic"
or bold oblique style instead of upright bold.
.
This is a Tenth Edition Research Unix extension.
.\" possibly 9th, but definitely not Berkeley
T}
_
\&.CW \f[R][\f[I]text\f[] [\f[I]post\f[] [\f[I]pre\f[]]]]	T{
As
.CW .B ,
but use a
.CW constant-width
(monospaced) roman typeface instead of bold.
.
This is a Tenth Edition Research Unix extension.
.\" possibly 9th, but definitely not Berkeley
T}
_
\&.BX \f[R][\f[I]text\f[]]	T{
Typeset
.I text
and draw a
.BX box
around it.
.
On terminal devices,
reverse video is used instead
(see the implementation note below).
.
If you want
.I text
to contain space,
use unbreakable space or horizontal motion escape sequences
.CW \[rs]\[ti] , (
.CW \[rs]\c
.I space ,
.CW \[rs]\[ha] ,
.CW \[rs]| ,
.CW \[rs]0 ,
or
.CW \[rs]h ).
T}
_
\&.UL \f[R][\f[I]text\f[] [\f[I]post\f[]]]	T{
Typeset
.I text
with an
.UL underline .
.
.I post,
if present,
is set after
.I text
with no intervening space.
T}
_
\&.LG	T{
Set subsequent text in
.LG
larger type
.NL
(2\~points larger than the current size)
until the next
type size,
paragraphing,
or heading macro call.
.
You can
.LG
specify this macro
.LG
multiple times
.NL
to enlarge the type size as needed.
T}
_
\&.SM	T{
Set subsequent text in
.SM
smaller type
.NL
(2\~points smaller than the current size)
until the next
type size,
paragraphing,
or heading macro call.
.
You can
.SM
specify this macro
.SM
multiple times
.NL
to reduce the type size as needed.
T}
_
\&.NL	T{
Set subsequent text at the normal type size
.CW \[rs]n[PS] ). (
T}
.TE
.
.
.PP
.I pre
and
.I post
arguments
are typically used to simplify the attachment of punctuation to styled
words.
When
.I pre
is used,
a hyphenation control escape sequence
.CW \[rs]%
that would ordinarily start
.I text
must start
.I pre
instead to have the desired effect.
.
.TS
box center;
Cb Cb
Lf(CR) L.
Input	Result
T{
.na
.nh
The CS course\[aq]s students found one C language keyword
.br
\&.CW static ) \[rs]%(
.br
most troublesome.
T}	T{
The CS course's students found one C language keyword
.CW static ) \%(
most troublesome.
T}
.TE
.
.KS
You can use the output line continuation escape sequence
.CW \[rs]c
to achieve the same result.
.
It is also portable to some older
.I ms
implementations. \" DWB 3.3 ms: no; Heirloom Doctools ms: yes
.
.TS
box center;
Cb Cb
Lf(CR) L.
Input	Result
T{
.na
.nh
The CS course\[aq]s students found one C language keyword
.br
\[rs]%(\[rs]c
.br
\&.CW static )
.br
most troublesome.
T}	T{
The CS course's students found one C language keyword
\%(\c
.CW static )
most troublesome.
T}
.TE
.KE
.
.
.PP
Rather than calling the
.CW CW
macro,
in
.I "groff ms"
you might prefer to change the font family to Courier by setting
.CW \[rs]*[FAM]
to
.CW C \[rq]. \[lq]
.
You can then use all four style macros above,
returning to the default family (Times) with
.CW ".ds FAM T" \[rq]. \[lq]
.
Because changes to
.CW \[rs]*[FAM]
take effect only at the next paragraph,
this document uses
.CW .CW
to \[lq]inline\[rq] a change to the font family,
marking syntactical elements of
.I ms
and
.I groff .
.
.
.KS
.PP
.I "groff ms"
also offers strings to begin and end super- and subscripting.
.
These are GNU extensions.
.
.
.TS
box;
lb lb
lf(CR) lx.
String	Description
_
\[rs]*{	Begin superscripting.
\[rs]*}	End superscripting.
_
\[rs]*<	Begin subscripting.
\[rs]*>	End subscripting.
.TE
.KE
.
.
.nr PS -2
.nr VS -2
.LP
.B1
.hy 0
.I "Implementation note:"
In
.CW nroff
mode,
the
.CW BX
macro \[lq]boxes\[rq] its argument by bracketing it with
.I groff
extension escape sequences to set the foreground color to black and the
background to white and then reset them to their previous values;
the terminal output driver,
.I grotty (1),
converts these to ISO\~6429 color escape sequences,
which may be ignored or mishandled by some terminals,
or may be disabled by
.I grotty 's
.CW \-c
option.
.
Further,
if the terminal is set up to use these colors in those roles already,
.CW .BX
will cause no visible effect in the output.
.
Surmounting these challenges would require adding features to
.I grotty ,
for instance to provide a mechanism to request ISO\~6429's
\[lq]standout\[rq] mode \" That's "smso" and "rmso" in terminfo.
(often supported on monochrome terminals),
or to replace the presumed support of the terminal for ISO\~6429 escape
sequences with the use of a library that can query the capabilities of
the terminal and adapt the output sent to the device accordingly.
.
(Practically,
this likely means adding a dependency on
.CW libtinfo .)
.
Contact the
.I groff
development mailing list if you'd like to contribute.
.sp \n[PD]/2
.B2
.nr PS +2
.nr VS +2
.
.
.NH 2
Lists
.XS
	Lists
.XE
.
.
.LP
The
.I marker
argument to the
.CW IP
macro can be employed to present a variety of lists;
for instance,
you can use a bullet glyph
.CW \[rs][bu] ) (
for unordered lists,
a number
(or auto-incrementing register)
for numbered lists,
or a word or phrase for glossary-style or definition lists.
.
If you set the paragraph indentation register
.CW PI
before calling
.CW IP ,
you can later reorder the items in the list without having to ensure
that a
.I width
argument remains affixed to the first call.
.
.
.TS H
box center;
cb cb
lf(CR) l .
Input	Result
_
.TH
T{
.nf
\&.nr PI 2n
A bulleted list:
\&.IP \[rs][bu]
lawyers
\&.IP \[rs][bu]
guns
\&.IP \[rs][bu]
money
.fi
T}	T{
.nr PI 2n
A bulleted list:
.IP \[bu]
lawyers
.IP \[bu]
guns
.IP \[bu]
money
T}
_
T{
.nf
\&.nr step 0 1
\&.nr PI 3n
A numbered list:
\&.IP \[rs]n+[step].
lawyers
\&.IP \[rs]n+[step].
guns
\&.IP \[rs]n+[step].
money
.fi
T}	T{
.nr step 0 1
.nr PI 3n
A numbered list:
.IP \n+[step].
lawyers
.IP \n+[step].
guns
.IP \n+[step].
money
T}
_
T{
.nf
A glossary-style list:
\&.IP lawyers 0.4i
Two or more attorneys.
\&.IP guns
Firearms,
preferably large-caliber.
\&.IP money
Gotta pay for those
lawyers and guns!
.fi
T}	T{
A glossary-style list:
.
.IP lawyers 0.4i
Two or more attorneys.
.IP guns
Firearms,
preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
.TE
.
.
.PP
In the enumerated list example,
we employed the
.CW nr
request to create a register of our own,
.CW step .
.
We initialized it to zero and assigned it an auto-increment of 1.
.
Each time we use the escape sequence
.CW \[rs]n+[PI]
(note the plus sign),
the formatter applies the increment just before interpolating the
register's value.
.
Preparing the
.CW PI
register as well enables us to rearrange the list without the tedium of
updating macro calls.
.
.
.PP
In the glossary example,
observe how the
.CW IP
macro places the definition on the same line as the term if it has
enough space.
.
If this is not what you want,
there are a few workarounds we will illustrate by modifying the example.
.
First,
you can use a
.CW br
request to force a break after printing the term or label.
.
Second,
you could apply the
.CW \[rs]p
escape sequence to force a break.
.
The space following the escape sequence is important;
if you omit it,
.I groff
prints the first word of the paragraph text on the same line as the term
or label
(if it fits)
.I then
breaks the line.
.
Finally,
you may append a horizontal motion to the marker with the
.CW \[rs]h
escape sequence;
using the same amount as the indentation will ensure that the marker is
too wide for
.I groff
to treat it as \[lq]fitting\[rq] on the same line as the paragraph text.
.
.
.TS
box center;
cb | cb | cb
lf(CR) | lf(CR)  | lf(CR).
Approach #1	Approach #2	Approach #3
_
T{
.nf
\&.IP guns
\&.br
Firearms,
.fi
T}	T{
.nf
\&.IP guns
\[rs]p Firearms,
.fi
T}	T{
.nf
\&.IP guns\[rs]h\[aq]0.4i\[aq]
Firearms,
.fi
T}
_
.T&
cb s s
l s s.
Result
_
T{
A glossary-style list:
.
.IP lawyers 0.4i
Two or more attorneys.
.IP guns\h\[aq]0.4i\[aq] 0.4i
Firearms,
preferably large-caliber.
.IP money
Gotta pay for those lawyers and guns!
T}
.TE
.
.
.NH 2
Indented regions
.XS
	Indented regions
.XE
.
.
.LP
You may need to indent a region of text while otherwise formatting it
normally.
.
Indented regions can be nested;
you can change
.CW \[rs]n[PI]
before each call to vary the amount of inset.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.RS	T{
Begin a region where headings,
paragraphs,
and displays are indented (further) by
.CW \[rs]n[PI] .
T}
\&.RE	T{
End the (next) most recent indented region.
T}
.TE
.
.
.PP
This feature enables you to easily line up text under hanging and
indented paragraphs.
.
For example,
you may wish to structure lists hierarchically.
.
.
.KS
.TS
box center;
cb cb
lf(CR)8 l .
Input	Result
_
T{
.nf
.CW
\&.IP \[rs][bu] 2
Lawyers:
\&.RS
\&.IP \[rs][bu]
Dewey,
\&.IP \[rs][bu]
Cheatham,
and
\&.IP \[rs][bu]
Howe.
\&.RE
\&.IP \[rs][bu]
Guns
.R
\&.\|.\|.
.fi
T}	T{
.IP \[bu] 2
Lawyers:
.RS
.IP \[bu]
Dewey,
.IP \[bu]
Cheatham,
and
.IP \[bu]
Howe.
.RE
.IP \[bu]
Guns
\&.\|.\|.
T}
.TE
.KE
.
.
.NH 2
Keeps, boxed keeps, and displays
.XS
	Keeps, boxed keeps, and displays
.XE
.
.
.LP
On occasion,
you may want to
.I keep
several lines of text,
or a region of a document,
together on a single page,
preventing an automatic page break within certain boundaries.
.
This can cause a page break to occur earlier than it normally would.
.
For example,
you may want to keep two paragraphs together,
or a paragraph that refers to a table,
list,
or figure adjacent to the item it discusses.
.
.I ms
provides the
.CW KS
and
.CW KE
macros for this purpose.
.
.
.PP
You can alternatively specify a
.I "floating keep:"
if a keep cannot fit on the current page,
.I ms
holds its contents and allows material following the keep
(in the source document)
to fill the remainder of the current page.
.
When the page breaks,
whether by reaching the end or
.CW bp
request,
.I ms
puts the floating keep at the beginning of the next page.
.
This is useful for placing large graphics or tables that do not need to
appear exactly where they occur in the source document.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.KS	Begin a keep.
\&.KF	Begin a floating keep.
_
\&.KE	End (floating) keep.
.TE
.
.
.PP
As an alternative to the keep mechanism,
the
.CW ne
request forces a page break if there is not at least the amount of
vertical space specified in its argument remaining on the page.
.
One application of
.CW ne
is to reserve space on the page for a figure or illustration to be
included later.
.
.
.KS
.PP
A
.I "boxed keep"
has a frame drawn around it.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.B1	Begin a keep with a box drawn around it.
\&.B2	End boxed keep.
.TE
.KE
.
.
.KS
.LP
Boxed keep macros cause breaks;
if you need to box a word or phrase within a line,
see the
.CW BX
macro in section \[lq]Typeface and decoration\[rq] above.
.
Box lines are drawn as close as possible to the text they enclose so
that they are usable within paragraphs.
.
If you wish to place one or more paragraphs in a boxed keep,
you may improve their appearance by calling
.CW .B1
after the first paragraphing macro,
and by adding a small amount of vertical space before calling
.CW .B2 .
.
.
.TS
box center;
lf(CR).
\&.LP
\&.B1
\&.I Warning:
Happy Fun Ball may suddenly accelerate to dangerous speeds.
\&.sp \[rs]n[PD]/2 \[rs]" space by half the inter-paragraph distance
\&.B2
.TE
.KE
.
.
.LP
If you want a boxed keep to float,
you will need to enclose the
.CW .B1
and
.CW .B2
calls within a pair of
.CW .KF
and
.CW .KE
calls.
.
.
.PP
.I Displays
turn off filling;
lines of verse or program code are shown with their lines broken as in
the source document without requiring
.CW br
requests between lines.
.
Displays can be kept on a single page or allowed to break across pages.
.
The
.CW DS
macro begins a kept display of the layout specified in its first
argument;
non-kept displays are begun with dedicated macros corresponding to their
layout.
.
.
.TS
box;
cb s | cb
cb cb | ^
lf(CR) lf(CR) | lx .
Display macro	Description
With keep	Without keep
_
\&.DS L	\&.LD	Begin left-aligned display.
\&.DS \f[R][\f[]I\f[R] [\,\f[I]indent\/\f[]]]	\
\&.ID \f[R][\,\f[I]indent\/\f[]]	T{
Begin display indented by
.I indent
if given,
.CW \[rs]n[DI]
otherwise.
T}
\&.DS B	\&.BD	T{
Begin block display
(left-aligned with longest line centered).
T}
\&.DS C	\&.CD	Begin centered display.
\&.DS R	\&.RD	T{
Begin right-aligned display.
This is a GNU extension.
T}
_
.T&
cf(CR) s | lx .
\&.DE	End any display.
.TE
.
.
.PP
The distance stored in
.CW \[rs]n[DD]
is inserted before and after each pair of display macros;
this is a Berkeley extension.
.
In
.I "groff ms" ,
this distance replaces any adjacent inter-paragraph distance
or subsequent spacing prior to a section heading.
.
The
.CW DI
register is a GNU extension;
its value is an indentation applied to displays created with
.CW .DS
and
.CW .ID
without arguments,
to
.CW .DS\~I \[rq] \[lq]
without an indentation argument,
and to equations set with
.CW .EQ\~I \[rq]. \[lq]
.
Changes to either register take effect at the next display boundary.
.
.
.KS
.NH 2
Tables, figures, equations, and references
.XS
	Tables, figures, equations, and references
.XE
.LP
The
.I ms
package is often used with the
.I tbl ,
.I pic ,
.I eqn ,
and
.I refer
preprocessors.
.
The
.CW \[rs]n[DD]
distance is also applied to regions of the document preprocessed with
.I tbl ,
.I pic ,
and
.I eqn .
.
Mark text meant for preprocessors by enclosing it in pairs of tokens as
follows,
with nothing between the dot and the macro name.
.
The preprocessors match these tokens only at the start of an input line.
.
.
.TS
box;
cb cb
lf(CR) lx .
Tag pair	Description
_
T{
\&.TS
.R
.CW H ] [
.CW
.br
\&.TE
T}	T{
Demarcate a table to be processed by the
.I tbl
preprocessor.
.
The optional
.CW H
argument to
.CW .TS
instructs
.I ms
to repeat table rows
(often column headings)
at the top of each new page the table spans,
if applicable;
calling the
.CW TH
macro marks the end of such rows.
.
The GNU
.I tbl (1)
man page provides a comprehensive reference to the preprocessor and
offers examples of its use.
T}
_
T{
\&.PS
.br
\&.PE
.br
\&.PF
T}	T{
.CW .PS
begins a picture to be processed by the
.I pic
preprocessor;
either of
.CW .PE
or
.CW .PF
ends it,
the latter with \[lq]flyback\[rq] to the vertical position at its top.
.
You can create
.I pic
input manually or with a program such as
.I xfig (1).
T}
_
T{
\&.EQ
.R
.I align \~[\c [
.I label ]]
.CW
.br
\&.EN
T}	T{
Demarcate an equation to be processed by the
.I eqn
preprocessor.
.
The equation is centered by default;
.I align
can be
.CW C ,
.CW L ,
or
.CW I
to (explicitly) center,
left-align,
or indent it by
.CW \[rs]n[DI] ,
respectively.
.
If specified,
.I label
is set right-aligned.
T}
_
T{
\&.[
.br
\&.]
T}	T{
Demarcate a bibliographic citation to be processed by the
.I refer
preprocessor.
.
The GNU
.I refer (1)
man page provides a comprehensive reference to the preprocessor and the
format of its bibliographic database.
T}
.TE
.KE
.
.
.PP
When
.I refer
emits collected references
(as might be done on a \[lq]Works Cited\[rq] page),
it interpolates the string
.CW \[rs]*[REFERENCES]
as an unnumbered heading
.CW .SH ). (
.
.
.KS
.PP
The following is an example of how to set up a table that may print
across two or more pages.
.
.
.TS
box center;
l .
T{
.nf
.CW
\&.TS H
allbox;
Cb | Cb .
Part\[->]Description
_
\&.TH
\&.T&
L | Lx .
GH-1978\[->]Fribulating gonkulator
.R
\&.\|.\|.\|the rest of the table follows\|.\|.\|.
.CW
\&.TE
.R
.fi
T}
.TE
.
.
Attempting to place a multi-page table inside a keep can lead to
unpleasant results,
particularly if the
.I tbl
.CW allbox
option is used.
.KE
.
.
.PP
Mathematics can be typeset using the language of the
.I eqn
preprocessor.
.
.
.TS
box center;
Lf(CR).
\&.EQ C (\[rs]*[SN\-NO\-DOT]a)
p \[ti] = \[ti] q sqrt { 1 + \[ti] ( x / q sup 2 ) }
\&.EN
.TE
.
.
This input formats a labelled equation.
.
We used the
.CW SN\-NO\-DOT
string to base the equation label on the current heading number,
giving us more flexibility to reorganize the document.
.
.
.EQ C (\*[SN-NO-DOT]a)
p ~ = ~ q sqrt { 1 + ~ ( x / q sup 2 ) }
.EN
.
Use
.I groff
options
to run preprocessors on the input:
.CW \-e
for
.I eqn ,
.CW \-p
for
.I pic ,
.CW \-R
for
.I refer ,
and
.CW \-t
for
.I tbl.
.
.
.KS
.NH 2
Footnotes
.XS
	Footnotes
.XE
.
.
.LP
.\" The following sentence is used below as an example as well.  Keep it
.\" in sync.
A footnote is typically anchored to a place in the text with a
.I marker,
which is a small integer,\**
.FS
like this numeric footnote
.FE
a symbol,\*{\[dg]\*}
.FS \[dg]
like this symbolic footnote
.FE
or arbitrary user-specified text.
.
.
.TS
box;
lb lb
lf(CR) lx.
String	Description
_
\[rs]**	T{
Place an
.I "automatic number,"
an automatically updated numeric footnote marker,
in the text.
.
Each time this string is interpolated,
the number it produces increments by one.
.
Automatic numbers start at 1.
.
This is a Berkeley extension.
T}
.TE
.KE
.
.
.PP
Enclose the footnote text in
.CW FS
and
.CW FE
macro calls to set it at the nearest available \[lq]foot\[rq],
or bottom,
of a text column or page.
.
.
.TS
box;
cb cb
lfCR lx .
Macro	Description
_
\&.FS \f[R][\f[I]marker\f[]]	T{
Begin a footnote.
.
The
.CW FS\-MARK
hook
(see below)
is called with any supplied
.I marker
argument,
which is then also placed at the beginning of the footnote text.
.
If
.I marker
is omitted,
the next pending automatic number enqueued by interpolation of the
.CW *
string is used,
and if none exists,
nothing is prefixed.
.
T}
_
\&.FE	End footnote text.
.TE
.
.
.PP
You may not desire automatically numbered footnotes in spite of their
convenience.
.
You can indicate a footnote with a symbol or other text by specifying
its marker at the appropriate place
(for example,
by using
.CW \[rs][dg]
for the dagger glyph)
.I and
as an argument to the
.CW FS
macro.
.
Such manual marks should be repeated as arguments to
.CW .FS
or as part of the footnote text to disambiguate their correspondence.
.
You may wish to use
.CW \[rs]*{
and
.CW \[rs]*}
to superscript the marker at the anchor point,
in the footnote text,
or both.
.
.
.PP
.I "groff ms"
provides a hook macro,
.CW FS\-MARK ,
for user-determined operations to be performed when the
.CW FS
macro is called.
.
It is passed the same arguments as
.CW FS
itself.
.
An application of
.CW FS\-MARK
is anchor placement for a hyperlink reference,
so that a footnote can link back to its referential context.\**
.
.FS
\[lq]Portable Document Format Publishing with GNU Troff\[rq],
.I pdfmark.ms
in the
.I groff
distribution,
uses this technique.
.FE
.
By default,
this macro has an empty definition.
.
.CW FS\-MARK
is a GNU extension.
.
.
.PP
The following input was used to produce the first sentence in this
section.
.
.
.TS
box center;
lfCR.
A footnote is anchored to a place in the text with a
\&.I marker,
which is a small integer,\[rs]**
\&.FS
like this numeric footnote
\&.FE
a symbol,\[rs]*{\[rs][dg]\[rs]*}
\&.FS \[rs][dg]
like this symbolic footnote
\&.FE
or arbitrary user-specified text.
.TE
.
.
.PP
Footnotes can be safely used within keeps and displays,
but you should avoid using automatically numbered footnotes within
floating keeps.
.
You can place a second
.CW \[rs]**
interpolation between a
.CW \[rs]**
and its corresponding
.CW .FS
call as long as each
.CW .FS
call occurs
.I after
the corresponding
.CW \[rs]**
and occurrences of
.CW .FS
are in the same order as corresponding occurrences of
.CW \[rs]** .
.
.
.PP
Footnote text is formatted as paragraphs are,
using analogous parameters.
.
The registers
.CW FI ,
.CW FPD ,
.CW FPS ,
and
.CW FVS
correspond to
.CW PI ,
.CW PD ,
.CW PS ,
and
.CW VS ,
respectively;
.CW FPD ,
.CW FPS ,
and
.CW FVS
are GNU extensions.
.
.
.KS
.PP
The
.CW FF
register controls the formatting of automatically numbered footnote
paragraphs,
and those for which
.CW .FS
is given a
.I marker
argument,
at the bottom of a column or page as follows.
.
.
.TS
box;
cb cb
lf(CR) lx .
\f[CB]FF\f[] value	Description
_
0	T{
Set an automatic number as a superscript
(on typesetter devices)
or surrounded by square brackets
(on terminals).
.
The footnote paragraph is indented as with
.CW .PP
if there is an
.CW .FS
argument or an automatic number,
and as with
.CW .LP
otherwise.
.
This is the default.
T}
1	T{
As
.CW 0 ,
but set the marker as regular text,
and follow an automatic number with a period.
T}
2	T{
As
.CW 1 ,
but without indentation
(like
.CW .LP ).
T}
3	T{
As
.CW 1 ,
but set the footnote paragraph with the marker hanging
(like
.CW .IP ).
T}
.TE
.KE
.
.
.PP
The default footnote line length is 11/12ths of the normal line length
for compatibility with the expectations of historical
.I ms
documents;
you may wish to set
.CW \[rs]*[FR]
to
.CW 1
to align with contemporary typesetting practices.
.
In the past,\**
.FS
Unix
Version\~7
.I ms ,
its descendants,
and
.I "groff ms"
prior to version 1.23.0
.FE
an
.CW FL
register was used for the line length in footnotes;
however,
setting this register at document initialization time had no effect on
the footnote line length in multi-column arrangements.\**
.
.FS
You could reset it after each call to
.CW .1C ,
.CW .2C ,
or
.CW .MC .
.FE
.
.
.PP
.CW \[rs]*[FR]
should be used in preference to
.CW \[rs]n[FL]
in contemporary documents.
.
The footnote line length is effectively computed as
.I column-width "" \[lq]
.CW "\~*\~\[rs]*[FR]" \[rq].
.
If an absolute footnote line length is required,
recall that arithmetic expressions in the
.I roff
language are evaluated strictly from left to right,
with no operator precedence
(parentheses are honored).
.
.
.TS
box center;
lf(CR).
\&.ds FR 0+3i \[rs]" Set footnote line length to 3 inches.
.TE
.
.
.LP \" continuing previous paragraph
Changes to the footnote length ratio
.CW \[rs]*[FR]
take effect with the next footnote written in single-column
arrangements,
but on the next page in multiple-column contexts.
.
.
.KS
.NH 2
Language and localization
.XS
	Language and localization
.XE
.
.
.LP
.I "groff ms"
provides several strings that you can customize for your own purposes,
or redefine to adapt the macro package to languages other than English.
.
It is already localized for
.\" cs, de, fr, it, sv
Czech,
German,
French,
Italian,
and
Swedish.
.
Load the desired localization macro package after
.I ms ;
see the
.I groff_tmac (5)
man page.
.
.
.TS
box center;
lf(CR).
$ \f[CB]groff \-ms \-mfr bienvenue.ms
.TE
.
.
.PP
The following strings are available.
.
.TS
box center;
cb lb
lf(CR) lf(CR) .
String	Default
_
\[rs]*[REFERENCES]	References
\[rs]*[ABSTRACT]	\[rs]f[I]ABSTRACT\[rs]f[]
\[rs]*[TOC]	Table of Contents
\[rs]*[MONTH1]	January
\[rs]*[MONTH2]	February
\[rs]*[MONTH3]	March
\[rs]*[MONTH4]	April
\[rs]*[MONTH5]	May
\[rs]*[MONTH6]	June
\[rs]*[MONTH7]	July
\[rs]*[MONTH8]	August
\[rs]*[MONTH9]	September
\[rs]*[MONTH10]	October
\[rs]*[MONTH11]	November
\[rs]*[MONTH12]	December
.TE
.
.
.PP
The default for
.CW \[rs]*[ABSTRACT]
includes font selection escape sequences to set the word in italics.
.KE
.
.
.KS
.NH 2
Glyphs for special characters
.XS
	Glyphs for special characters
.XE
.
.
.LP
Some of the special character escape sequences used in this document
are listed below.
.
The minus sign glyph can also be accessed by the shorthand
.CW \[rs]\[mi] .
.
These and many others are documented in the
.I groff_char (7)
man page.
.
.
.TS
box center;
Cb Lb Lb
Lf(CR) L L .
Input	Appearance	Description
_
\[rs][\-]	\[mi]	minus sign
\[rs][\->]	\[->]	right arrow
\[rs][aq]	\[aq]	neutral apostrophe
\[rs][bu]	\[bu]	bullet
\[rs][dq]	\[dq]	neutral double quote
\[rs][dg]	\[dg]	dagger
\[rs][em]	\[em]	em dash
\[rs][ha]	\[ha]	circumflex accent (caret, hat)
\[rs][lg]	\[lq]	left double quotation mark
\[rs][rq]	\[rq]	right double quotation mark
\[rs][rs]	\[rs]	reverse solidus (backslash)
\[rs][sd]	\[sd]	seconds (double prime) mark
\[rs][ti]	\[ti]	tilde
.TE
.KE
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Page layout
.XS
Page layout
.XE
.LP
.I ms 's
default page layout arranges text
in a single column
with the page number
between hyphens
centered in a header
on each page
except the first,
and produces no footers.
.
You can customize this arrangement.
.
.
.NH 2
Headers and footers
.XS
	Headers and footers
.XE
.
.
.LP
There are multiple ways to produce headers and footers.
.
One is to define the strings
.CW LH ,
.CW CH ,
and
.CW RH
to set the left,
center,
and right headers,
respectively;
and
.CW LF ,
.CW CF ,
and
.CW RF
to set the left,
center,
and right footers.
.
This approach suffices for documents that do not distinguish odd- and
even-numbered pages.
.
.
.PP
Another method is to call macros that set headers or footers for odd- or
even-numbered pages.
.
Each such macro takes a delimited argument separating the left,
center,
and right header or footer texts from each other.
.
You can replace the neutral apostrophes (\[aq]) shown below with any
character not appearing in the header or footer text.
.
These macros are Berkeley extensions.
.
.
.TS
box;
lb lb
lf(CR) lx.
Macro	Description
_
\&.OH \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	T{
Set the left, center, and right headers on odd-numbered (recto) pages.
T}
\&.OF \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	T{
Set the left, center, and right footers on odd-numbered (recto) pages.
T}
\&.EH \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	T{
Set the left, center, and right headers on even-numbered (verso) pages.
T}
\&.EF \[aq]\f[I]left\f[]\[aq]\f[I]center\f[]\[aq]\f[I]right\f[]\[aq]\
	T{
Set the left, center, and right footers on even-numbered (verso) pages.
T}
.TE
.
.
.PP
With either method,
a percent sign
.B %
in header or footer text is replaced by the current page number.
.
By default,
.I ms
places no header on a page numbered \[lq]1\[rq]
(regardless of its number format).
.
.
.TS
box;
lb lb
lf(CR) lx.
Macro	Description
_
\&.P1	T{
Typeset the header even on page\~1.
.
To be effective,
this macro must be called before the header trap is sprung on any page
numbered \[lq]1\[rq];
in practice,
unless your page numbering is unusual,
this means that you should call it early,
before
.CW .TL
or any heading or paragraphing macro.
.
This is a Berkeley extension.
T}
.TE
.
.
.PP
For even greater flexibility,
.I ms
is designed to permit the redefinition of the macros that are called
when the
.I groff
traps that ordinarily cause the headers and footers to be output are
sprung.
.
.CW PT
(\[lq]page trap\[rq])
is called by
.I ms
when the header is to be written,
and
.CW BT
(\[lq]bottom trap\[rq])
when the footer is to be.
.
The
.I groff
page location trap that
.I ms
sets up to format the header also calls the
(normally undefined)
.CW HD
macro after
.CW .PT ;
you can define
.CW .HD
if you need additional processing after setting the header
(for example,
to draw a line below it).
.
.\" Although undocumented in Tuthill's 4.2BSD ms.diffs paper...
The
.CW HD
hook is a Berkeley extension.
.
Any such macros you (re)define must implement any desired specialization
for odd-,
even-,
or first numbered pages.
.
.
.KS
.NH 2
Tab stops
.XS
	Tab stops
.XE
.
.
.LP
Use the
.CW ta
request to set tab stops as needed.
.
.
.TS
box;
lb lb
lf(CR) lx.
Macro	Description
_
\&.TA	T{
Reset the tab stops to the
.I ms
default
(every 5 ens).
.
Redefine this macro to create a different set of default tab stops.
T}
.TE
.KE
.
.
.KS
.NH 2
Margins
.XS
	Margins
.XE
.
.
.LP
Control margins using the registers summarized in the \[lq]Margins\[rq]
portion of the table in section \[lq]Document control settings\[rq]
above.
.
There is no setting for the right margin;
the combination of page offset
.CW \[rs]n[PO]
and line length
.CW \[rs]n[LL]
determines it.
.KE
.
.
.KS
.NH 2
Multiple columns
.XS
	Multiple columns
.XE
.
.
.LP
.I ms
can set text in as many columns as reasonably fit on the page.
.
The following macros force a page break if a multi-column layout is
active when they are called.
.
.CW \[rs]n[MINGW]
is the default minimum gutter width;
it is a GNU extension.
.
When multiple columns are in use,
keeps
and the
.CW \%HORPHANS
and
.CW \%PORPHANS
registers
work with respect to column breaks instead of page breaks.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.1C	T{
Arrange page text in a single column (the default).
T}
_
\&.2C	T{
Arrange page text in two columns.
T}
_
\&.MC \f[R][\f[I]column-width\f[] [\f[I]gutter-width\f[]]]	T{
Arrange page text in multiple columns.
.
If you specify no arguments,
it is equivalent to the
.CW 2C
macro.
.
Otherwise,
.I column-width
is the width of each column and
.I gutter-width
is the minimum distance between columns.
T}
.TE
.KE
.
.
.\" ------------------------
.NH 2
Creating a table of contents
.XS
	Creating a table of contents
.XE
.LP
Because
.I roff
formatters process their input in a single pass,
material on page 50,
for example,
cannot influence what appears on page\~1\[em]this poses a challenge for
a table of contents at its traditional location in front matter,
if you wish to avoid manually maintaining it.
.
.I ms
enables the collection of material to be presented in the table of
contents as it appears,
saving its page number along with it,
and then emitting the collected contents on demand toward the end of the
document.
.
The table of contents can then be resequenced to its desired location
by physically rearranging the pages of a printed document,
or as part of post-processing\[em]with a
.I sed (1)
script to reorder the pages in
.I troff 's
output,
with
.I pdfjam (1),
or with
.I gropdf (1)'s
.B .pdfswitchtopage
feature,
for example.
.
.
.PP
Define an entry to appear in the table of contents by bracketing its
text between calls to the
.CW XS
and
.CW XE
macros.
.
A typical application is to call them immediately after
.CW NH
or
.CW SH
and repeat the heading text within them.
.
The
.CW XA
macro,
used within
.CW .XS /\c
.CW .XE
pairs,
supplements an entry\[em]for instance,
when it requires multiple output lines,
whether because a heading is too long to fit or because style dictates
that page numbers not be repeated.
.
You may wish to indent the text thus wrapped to correspond to its
heading depth;
this can be done in the entry text by prefixing it with tabs or
horizontal motion escape sequences,
or by providing a second argument to the
.CW XA
macro.
.
.CW .XS
and
.CW .XA
automatically associate the page number where they are called with the
text following them,
but they accept arguments to override this behavior.
.
At the end of the document,
call
.CW TC
or
.CW PX
to emit the table of contents;
.CW .TC
resets the page number
.B i "" to\~
(Roman numeral one),
and then calls
.CW PX .
.
All of these macros are Berkeley extensions.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.XS \f[R][\f[I]page-number\f[]]	T{
Begin,
supplement,
and end a table of contents entry.
.
Each entry is associated with
.I page-number
(otherwise the current page number);
a
.I page-number
of
.CW no
prevents a leader and page number from being emitted for that entry.
.
Use of
.CW .XA
within
.CW .XS /\c
.CW .XE
is optional;
it can be repeated.
.
If
.I indentation
is present,
a supplemental entry is indented by that amount;
ens are assumed if no unit is indicated.
.
Text on input lines between
.CW .XS
and
.CW .XE
is stored for later recall by
.CW .PX .
T}
\&.XA \f[R][\f[I]page-number\f[] [\f[I]indentation\f[]]]	\^
\&.XE	\^
_
\&.PX \f[R][\f[]no\f[R]]	T{
Switch to single-column layout.
.
Unless
.CW no
is specified,
center and interpolate
.CW \[rs]*[TOC]
in bold and two points larger than the body text.
.
Emit the table of contents entries.
T}
_
\&.TC \f[R][\f[]no\f[R]]	T{
Set the page number to\~1,
the page number format to lowercase Roman numerals,
and call
.CW PX
(with a
.CW no
argument,
if present).
T}
.TE
.
.
.KS
.PP
Here's an example of typical
.I ms
table of contents preparation and
its result.
.
We employ horizontal escape sequences
.CW \[rs]h
to indent the entries by sectioning depth.
.
.TS
box center;
L.
T{
.nf
.CW
\&.NH 1
Introduction
\&.XS
Introduction
\&.XE
.R
\&.\|.\|.
.CW
\&.NH 2
Methodology
\&.XS
\[rs]h\[aq]2n\[aq]Methodology
\&.XA no
\[rs]h\[aq]4n\[aq]Fassbinder\[aq]s Approach
\&.XA no
\[rs]h\[aq]4n\[aq]Kahiu\[aq]s Approach
\&.XE
.R
\&.\|.\|.
.CW
\&.NH 1
Findings
\&.XS
Findings
\&.XE
.R
\&.\|.\|.
.CW
\&.TC
.fi
T}
.TE
.KE
.
.nr SavedPageNumber \n%
.nr SavedH1 \n[H1] \" groff ms internal name
.nr SavedH2 \n[H2] \" groff ms internal name
.nr % 1
.rr H1
.rr H2
.als SavedTOC toc*div \" groff ms internal name
.rm toc*div
.di ThrowAway
.NH 1
Introduction
.XS
Introduction
.XE
.nr % 2
.NH 2
Methodology
.XS
\h'2n'Methodology
.XA no
\h'4n'Fassbinder's Approach
.XA no
\h'4n'Kahiu's Approach
.XE
.nr % 5
.NH 1
Findings
.XS
Findings
.XE
.br
.di
.\" We can't emit the TOC inside a B1/B2 box, so use lines instead.
.R
\l'\n[.l]u'
.PX
\l'\n[.l]u'
.als toc*div SavedTOC
.rm SavedTOC
.nr % \n[SavedPageNumber]
.nr H1 \n[SavedH1]
.nr H2 \n[SavedH2]
.rr SavedPageNumber
.rr SavedH1
.rr SavedH2
.
.
.PP
The remaining features in this subsection are GNU extensions.
.
.I "groff ms"
obviates the need to repeat heading text after
.CW XS
calls.
.
Call
.CW XN
and
.CW XH
after
.CW NH
and
.CW SH ,
respectively.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.XN \f[I]heading-text	T{
Format
.I heading-text
and create a corresponding table of contents entry;
the indentation is computed from the depth of the preceding
.CW NH
call.
T}
\&.XH \f[I]depth heading-text	T{
As
.CW .XN ,
but use
.I depth
to determine the indentation.
T}
.TE
.
.
.KS
.PP
.I "groff ms"
encourages customization of table of contents entry production.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.XN\-REPLACEMENT \f[I]heading-text	T{
These hook macros implement
.CW .XN
and
.CW .XH ,
respectively.
.
They call
.CW \%XN\-INIT
and
pass their
.I heading-text
arguments to
.CW .\%XH\-UPDATE\-TOC .
T}
\&.XH\-REPLACEMENT \f[I]depth heading-text	\^
\&.XH\-INIT	T{
This hook macro does nothing by default.
T}
\&.XH\-UPDATE\-TOC\~ \f[I]depth heading-text	T{
Bracket
.I heading-text
with
.CW XS
and
.CW XE
calls,
indenting it by 2 ens per level of
.I depth
beyond the first.
T}
.TE
.KE
.
.
.LP
.TS
box center;
L.
T{
.nf
.CW
\&.NH 1
\&.XN Introduction
.R
\&.\|.\|.
.CW
\&.NH 2
\&.XN Methodology
\&.XH 3 \[dq]Fassbinder\[aq]s Approach\[dq]
\&.XH 3 \[dq]Kahiu\[aq]s Approach\[dq]
.R
\&.\|.\|.
.CW
\&.NH 1
\&.XN Findings
.R
\&.\|.\|.
.CW
\&.TC
.fi
T}
.TE
.
.nr SavedPageNumber \n%
.nr SavedH1 \n[H1] \" groff ms internal name
.nr SavedH2 \n[H2] \" groff ms internal name
.nr % 1
.rr H1
.rr H2
.als SavedTOC toc*div \" groff ms internal name
.rm toc*div
.di ThrowAway
.NH 1
.XN Introduction
.nr % 2
.NH 2
.XN Methodology
.XH 3 "Fassbinder's Approach"
.XH 3 "Kahiu's Approach"
.nr % 5
.NH 1
.XN Findings
.br
.di
.\" We can't emit the TOC inside a B1/B2 box, so use lines instead.
.R
\l'\n[.l]u'
.PX
\l'\n[.l]u'
.als toc*div SavedTOC
.rm SavedTOC
.nr % \n[SavedPageNumber]
.nr H1 \n[SavedH1]
.nr H2 \n[SavedH2]
.rr SavedPageNumber
.rr SavedH1
.rr SavedH2
.
.
.PP
To get the section number of the numbered headings into the table of
contents entries,
we might define
.CW \%XN\-REPLACEMENT
as follows.
.
(We obtain the heading depth from
.I "groff ms" 's
internal register
.CW nh*hl .)
.
.
.LP
.TS
box center;
L.
T{
.nf
.CW
\&.de XN\-REPLACEMENT
\&.XN\-INIT
\&.XH\-UPDATE\-TOC \[rs]\[rs]n[nh*hl] \[rs]\[rs]$@
\&\[rs]&\[rs]\[rs]*[SN] \[rs]\[rs]$*
\&..
T}
.TE
.
.
.PP
You can change the style of the leader that bridges each table of
contents entry with its page number;
define the
.CW TC\-LEADER
special character by using the
.CW char
request.
.
A typical leader combines the dot glyph
.CW .\& \[rq] \[lq]
with a horizontal motion escape sequence to spread the dots.
.
The width of the page number field is stored in the
.CW TC\-MARGIN
register.
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Differences from AT&T
.BI ms
.XS
Differences from AT&T
.I ms
.XE
.LP
The
.I "groff ms"
macros are an independent reimplementation,
using no AT&T code.
.
Since they take advantage of the extended features of
.I groff ,
they cannot be used with AT&T
.I troff .
.
.I "groff ms"
supports features described above as Berkeley and Tenth Edition Research
Unix extensions,
and adds several of its own.
.
.
.PP
The internals of
.I "groff ms"
differ from those of AT&T
.I ms .
.
Documents that depend upon implementation details of AT&T
.I ms
may not format properly with
.I "groff ms" .
.
Such details include macros whose function was not documented in the
AT&T
.I ms
manual [Lesk 1978].
.\" TODO: Use refer(1).
.\" XXX: We support RT anyway; maybe we should stop?
.
.
.PP
The error-handling policy of
.I "groff ms"
is to detect and report errors,
rather than to ignore them silently.
.
.
.PP
Tenth Edition \" possibly 9th
Research Unix supported
.B P1 /
.B P2
macros to bracket code examples;
.I "groff ms"
does not.
.
.
.PP
.I "groff ms"
does not work in GNU
.I troff 's \" GNU
AT&T compatibility mode.
.
If loaded when that mode is enabled,
it aborts processing with a diagnostic message.
.
.
.PP
Multiple line spacing is not supported.
.
Use a larger vertical spacing instead.
.
.
.PP
.I "groff ms"
uses the same header and footer defaults in both
.CW nroff
and
.CW troff
modes
as AT&T
.I ms
does in
.CW troff
mode;
AT&T's default in
.CW nroff
mode is to put the date,
in U.S.\& traditional format
(e.g.,
\[lq]January 1, 2021\[rq]),
in the center footer
(the
.CW CF
string).
.
.
.PP
Many
.I "groff ms"
macros,
including those for paragraphs,
headings,
and displays,
cause a reset of formatting parameters,
and may change the indentation;
they do so not by incrementing or decrementing it,
but by setting it absolutely.
.
This can cause problems for documents that define additional macros of
their own that try to manipulate indentation.
.
Use
.CW .RS
and
.CW .RE
instead of the
.CW in
request.
.
.
.PP
AT&T
.I ms
interpreted the values of the registers
.CW PS
and
.CW VS
in points,
and did not support the use of scaling units with them.
.
.I "groff ms"
interprets values of the registers
.CW PS ,
.CW VS ,
.CW FPS ,
and
.CW FVS
equal to or larger than\~1,000
(one thousand)
as decimal fractions multiplied by\~1,000.\**
.FS
Register values are converted to and stored as basic units.
.
See \[lq]Measurements\[rq] in the
.I groff
Texinfo manual or in
.I groff (7).
.FE
.
This threshold makes use of a scaling unit with these parameters
practical for high-resolution devices while preserving backward
compatibility.
.
It also permits expression of non-integral type sizes.
.
For example,
.CW "groff \-rPS=10.5p" \[rq] \[lq]
at the shell prompt is equivalent to placing
.CW ".nr PS 10.5p" \[rq] \[lq]
at the beginning of the document.
.
.
.PP
AT&T
.I ms 's
.CW AU
macro supported arguments used with some document types;
.I "groff ms"
does not.
.
.
.PP
Right-aligned displays are available.
.
The AT&T
.I ms
manual observes that \[lq]it is tempting to assume that
.CW ".DS R"
will right adjust lines,
but it doesn't work\[rq].
.
In
.I "groff ms" ,
it does.
.
.
.PP
To make
.I "groff ms"
use the default page offset
(which also specifies the left margin),
the
.B PO
register must stay undefined until the first
.I ms
macro is called.
.
This implies that
.B \[rs]n[PO]
should not be used early in the document,
unless it is changed also:
accessing an undefined register automatically defines it.
.
.
.PP
.I "groff ms"
supports the
.CW PN
register,
but it is not necessary;
you can access the page number via the usual
.CW %
register and invoke the
.CW af
request to assign a different format to it if desired.\**
.FS
If you redefine the
.I ms
.CW PT
macro \" I wouldn't mention that, but Lesk 1978 encourages doing so. :-/
and desire special treatment of certain page numbers
(like
.CW 1 \[rq]), \[lq]
you may need to handle a non-Arabic page number format,
as
.I "groff ms" 's
.CW .PT
does;
see the macro package source.
.
.I "groff ms"
aliases the
.CW PN
register to
.CW % .
.FE
.
.
.PP
The AT&T
.I ms
manual documents registers
.CW CW
and
.CW GW
as setting the default column width and \[lq]intercolumn gap\[rq],
respectively,
and which applied when
.CW .MC
was called with fewer than two arguments.
.
.I "groff ms"
instead treats
.CW .MC
without arguments as synonymous with
.CW .2C ;
there is thus no occasion for a default column width register.
.
Further,
the
.CW MINGW
register
and the second argument to
.CW .MC
specify a
.I minimum
space between columns,
not the fixed gutter width of AT&T
.I ms .
.
.
.PP
The AT&T
.I ms
manual did not document the
.CW QI
register;
Berkeley and
.I "groff ms"
do.
.
.
.PP
The register
.CW GS
is set to\~1 by the
.I "groff ms"
macros,
but is not used by the AT&T
.I ms
package.
.
Documents that need to determine whether they are being formatted with
.I "groff ms"
or another implementation should test this register.
.
.
.\" XXX: We can't use a keep here because the wrong page number will be
.\" recorded in the table of contents; see Savannah #63159.
.\"KS
.br
.ne 6v
.NH 2
Unix Version\~7
.BI ms
macros not implemented by
.BI "groff ms"
.XS
	Unix Version 7
.I ms
macros not implemented by
.I "groff ms"
.XE
.LP
Several macros described in the Unix Version\~7
.I ms
documentation are unimplemented by
.I "groff ms"
because they are specific to the requirements of documents produced
internally by Bell Laboratories,
some of which also require a glyph for the Bell System logo that
.I groff
does not support.
.
These macros implemented several document type formats
(\c
.CW EG , \" engineer's notes
.CW IM , \" internal memorandum
.CW MF , \" memorandum for file
.CW MR , \" memorandum for record
.CW TM , \" technical memorandum
.CW TR ), \" technical report
were meaningful only in conjunction with the use of certain document
types
(\c
.CW AT , \" attachments
.CW CS , \" cover sheet info for `TM` documents
.CW CT , \" copies to
.CW OK , \" "other keywords" for `TM` documents
.CW SG ), \" signatures for `TM` documents
stored the postal addresses of Bell Labs sites
(\c
.CW HO , \" Holmdel
.CW IH , \" Naperville
.CW MH , \" Murray Hill
.CW PY , \" Piscataway
.CW WH ), \" Whippany
or lacked a stable definition over time
(\c
.CW UX ). \" Unix; on 1st use, add footnote identifying trademark owner
.
To compatibly render historical
.I ms
documents using these macros,
we advise your documents to invoke the
.CW rm
request to remove any such macros it uses and then define replacements
with an authentically typeset original at hand.\**
.FS
The removal beforehand is necessary because
.I "groff ms"
aliases these macros to a diagnostic macro,
and you want to redefine the aliased name,
not its target.
.FE
.
For informal purposes,
a simple definition of
.CW UX
should maintain the readability of the document's substance.
.
.
.TS
box center;
lf(CR).
\&.rm UX
\&.ds UX Unix\[rs]"
.TE
.rs \" XXX: Work around Savannah #64005.
.\"KE
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Legacy features
.XS
Legacy features
.XE
.
.
.LP
.I "groff ms"
retains some legacy features solely to support formatting of historical
documents;
contemporary ones should not use them because they can render poorly.
.
See
.I groff_char (7)
instead.
.
.
.KS
.NH 2
AT&T
.I ms
accent mark strings
.XS
	AT&T
.I ms
accent mark strings
.XE
.LP
AT&T
.I ms
defined
accent mark strings as follows.
.
.
.TS
box center;
Cb Lb
Lf(CR) Lx.
String	Description
_
\[rs]*[\[aq]]	Apply acute accent to subsequent glyph.
\[rs]*[\[ga]]	Apply grave accent to subsequent glyph.
\[rs]*[:]	Apply dieresis (umlaut) to subsequent glyph.
\[rs]*[\[ha]]	Apply circumflex accent to subsequent glyph.
\[rs]*[\[ti]]	Apply tilde accent to subsequent glyph.
\[rs]*[C]	Apply caron to subsequent glyph.
.\" \*v was an undocumented (in Lesk 1978-11-13) synonym for \*C.
\[rs]*[,]	Apply cedilla to subsequent glyph.
.TE
.KE
.
.
.NH 2
Berkeley
.I ms
accent mark and glyph strings
.XS
	Berkeley
.I ms
accent mark and glyph strings
.XE
.LP
Berkeley
.I ms
offered an
.CW AM
macro;
calling it redefined the AT&T accent mark strings
(except for
.CW \[rs]*C ),
applied them to the
.I preceding
glyph,
and defined additional strings,
some for spacing glyphs.
.
.
.TS
box;
cb cb
lf(CR) lx .
Macro	Description
_
\&.AM	Enable alternative accent mark and glyph-producing strings.
.TE
.
.
.TS
box center;
Cb Lb
Lf(CR) Lx.
String	Description
_
\[rs]*[\[aq]]	Apply acute accent to preceding glyph.
\[rs]*[\[ga]]	Apply grave accent to preceding glyph.
\[rs]*[:]	Apply dieresis (umlaut) to preceding glyph.
\[rs]*[\[ha]]	Apply circumflex accent to preceding glyph.
\[rs]*[\[ti]]	Apply tilde accent to preceding glyph.
\[rs]*[,]	Apply cedilla to preceding glyph.
\[rs]*[/]	Apply stroke (slash) to preceding glyph.
\[rs]*[v]	Apply caron to preceding glyph.
\[rs]*[_]	Apply macron to preceding glyph.
\[rs]*[.]	Apply underdot to preceding glyph.
\[rs]*[o]	Apply ring accent to preceding glyph.
_
\[rs]*[?]	Interpolate inverted question mark.
\[rs]*[!]	Interpolate inverted exclamation mark.
\[rs]*[8]	Interpolate small letter sharp s.
\[rs]*[q]	Interpolate small letter o with hook accent (ogonek).
\[rs]*[3]	Interpolate small letter yogh.
\[rs]*[d-]	Interpolate small letter eth.
\[rs]*[D-]	Interpolate capital letter eth.
\[rs]*[th]	Interpolate small letter thorn.
\[rs]*[TH]	Interpolate capital letter thorn.
\[rs]*[ae]	Interpolate small ae ligature.
\[rs]*[AE]	Interpolate capital ae ligature.
\[rs]*[oe]	Interpolate small oe ligature.
\[rs]*[OE]	Interpolate capital oe ligature.
.TE
.rs \" XXX: Work around Savannah #64005.
.
.
.\" ------------------------
.if t \{\
.  br
.  bp
.\}
.NH 1
Further reading
.XS
Further reading
.XE
.
.
.XP
\[lq]Typing Documents on the Unix System:
Using the \-ms Macros with Troff and Nroff\[rq];
M.\& E.\& Lesk;
November 13, 1978.
.
This document describes the
.I ms
supplied with AT&T Unix Version\~7.
.
.
.XP
\[lq]A Revised Version of \-ms\[rq];
Bill Tuthill;
August 1983.
.
The 4.2BSD release featured several extensions to
.I ms ,
most of which are recreated in
.I "groff ms" .
.
(The exceptions are the
.CW TM
and
.CW CT
macros for setting a doctoral thesis in the format required by the
contemporaneous degree-granting authorities of the University of
California at Berkeley.)
.
.
.XP
\[lq]Using PDF boxes with
.I groff
and the
.I ms
macros\[rq];
Deri James;
March 2021.
.
.CW BOXSTART
and
.CW BOXSTOP
macros are available via the
.I sboxes
extension package,
enabling colored,
bordered boxes when the
.CW pdf
output device is used.
.
This document is distributed with
.I groff
as the file
.I msboxes.pdf .
.
.
.LP
This manual was composed using
.I "groff ms" ;
the curious may consult its source in the file
.I ms.ms
to see how its formatting was achieved.
.\" ------------------------
.TC
.
.
.\" Local Variables:
.\" fill-column: 72
.\" mode: nroff
.\" End:
.\" vim: set filetype=groff textwidth=72:
