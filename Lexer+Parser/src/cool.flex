/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
  if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
    YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

%option noyywrap

/*
 * Define names for regular expressions here.
 */

digit       [0-9]

%x oneline_comment
%x block_comment
%%

 /*
  * Define regular expressions for the tokens of COOL here. Make sure, you
  * handle correctly special cases, like:
  *   - Nested comments
  *   - String constants: They use C like systax and can contain escape
  *     sequences. Escape sequence \c is accepted for all characters c. Except
  *     for \n \t \b \f, the result is c.
  *   - Keywords: They are case-insensitive except for the values true and
  *     false, which must begin with a lower-case letter.
  *   - Multiple-character operators (like <-): The scanner should produce a
  *     single token for every such operator.
  *   - Line counting: You should keep the global variable curr_lineno updated
  *     with the correct line number
  */

 /* regex patterns for keywords. */
(?i:"class") {return CLASS;}
(?i:"else") return ELSE;
(?i:"fi") return FI;
(?i:"if") return IF;
(?i:"in") return IN;
(?i:"inherits") return INHERITS;
(?i:"let") return LET;
(?i:"loop") return LOOP;
(?i:"pool") return POOL;
(?i:"then") return THEN;
(?i:"while") return WHILE;
(?i:"case") return CASE;
(?i:"esac") return ESAC;
(?i:"of") return OF;
(?i:"new") return NEW;
(?i:"isvoid") return ISVOID;
(?i:"not") return NOT;

t(?i:"rue") {
  cool_yylval.boolean = true;
  return BOOL_CONST;
}

f(?i:"alse") {
  cool_yylval.boolean = false;
  return BOOL_CONST;
}

[0-9]+ { 
  cool_yylval.symbol = inttable.add_string(yytext); 
  return INT_CONST;
}

[A-Z][a-zA-Z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

[a-z][a-zA-Z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

 /* pattern-actions for one-line comments */
-- BEGIN(oneline_comment);
<oneline_comment>[^\n] /* eat anything that's not a new line */
<oneline_comment>\n { curr_lineno++; BEGIN(INITIAL);}
<oneline_comment><<EOF>> BEGIN(INITIAL);

 /* pattern-actions for block comments */
"(*" BEGIN(block_comment);
<block_comment>[^*\n]* /* eat anything but * or new line */
<block_comment>"*"+[^)\n]* /* eat any * that's not followed by ) */
<block_comment>\n { curr_lineno++; }
<block_comment>"*)" {BEGIN(INITIAL);}

"{"|"}"|";"|"("|")"|":"|"*" { 
  return yytext[0];
}


\n {
  curr_lineno++;
}

[ \f\r\t\v] /* eat all those */
%%
