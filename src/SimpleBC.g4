grammar SimpleBC;

/*parser rules */
exprList: topExpr ( EXPR_END topExpr)* EXPR_END? ;

varDef: VAR ID '=' expr;

topExpr: 
      expr { System.out.println("Result: "+ Double.toString($expr.i));} 
    ;

expr returns [double i]:
      el=expr op='*' er=expr { $i=$el.i*$er.i; }
    | el=expr op='/' er=expr { $i=$el.i/$er.i; }
    | el=expr op='+' er=expr { $i=$el.i+$er.i; }
    | el=expr op='-' er=expr { $i=$el.i-$er.i; }
    | INT { $i=Double.parseDouble($INT.text); }
    | ID
    | '(' e=expr ')'
    ;

//comment: COMMENT;

/*token definition*/
COMMENT: [/][*](.)*?[*][/] -> skip;
/*
Comments is defined with the lazy definition so that 
we match the nearest * /
*/


VAR: 'var';  // keyword
ID: [_A-Za-z]+;
INT: [0-9]+ ;
EXPR_END: [\n\r;];
WS : [ \t]+ -> skip ;