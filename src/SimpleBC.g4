grammar SimpleBC;

/* Include Java libraries */
@header{
    import java.util.HashMap;
    import java.util.Scanner;
    import java.math.BigDecimal;
}

/* Global Java code */
@members{
    // Input for functions
    public static Scanner input = new Scanner(System.in);

    // Define function interface and map
    public interface Fn {
        public double execute(double arg);
    }

    public static HashMap<String, Fn> fnMap = new HashMap<String, Fn>();

    // Default functions
    static {
        fnMap.put("sqrt", new Fn() { public double execute(double arg) { return Math.sqrt(arg); } });
        fnMap.put("s", new Fn() { public double execute(double arg) { return Math.sin(arg); } });
        fnMap.put("c", new Fn() { public double execute(double arg) { return Math.cos(arg); } });
        fnMap.put("l", new Fn() { public double execute(double arg) { return Math.log(arg); } });
        fnMap.put("e", new Fn() { public double execute(double arg) { return Math.pow(Math.E, arg); } });
    }

    // Variable map
    public static HashMap<String, BigDecimal> varMap = new HashMap<>();
    public static BigDecimal getOrCreate(String id) {
        if (varMap.containsKey(id)) {
            return varMap.get(id);
        } else {
            varMap.put(id, BigDecimal.ZERO);
            return BigDecimal.ZERO;
        }
    }

    // Defualt variables
    static {
        varMap.put("last", BigDecimal.ZERO);
    }
}

/* Parser rules */
exprList: (topExpr? EXPR_END)*;

/* value assignments in bc return the value
however, if you only assign the value,
the statement the result is not printed */
varDef returns [BigDecimal i]: ID '=' arithExpr { varMap.put($ID.text, $arithExpr.i); $i=$arithExpr.i; } ;

topExpr:
      varDef
    | printStatment {System.out.println($printStatment.i); }
    | arithExpr { varMap.put("last", $arithExpr.i); System.out.println($arithExpr.i); }
    ;

printStatment returns [String i]:
        'print' {$i = "";} ((arithExpr {$i += $arithExpr.i;} | '"' s=ID '"' {$i += $s.text;}) ',')* (arithExpr {varMap.put("last", $arithExpr.i); $i += $arithExpr.i;} | '"' s=ID '"' {$i += $s.text;})
        ;

arithExpr returns [BigDecimal i]:
      op='++' ID { BigDecimal oldVal = getOrCreate($ID.text); varMap.put($ID.text, oldVal.add(BigDecimal.ONE)); $i=oldVal.add(BigDecimal.ONE); }
    | op='--' ID { BigDecimal oldVal = getOrCreate($ID.text); varMap.put($ID.text, oldVal.subtract(BigDecimal.ONE)); $i=oldVal.subtract(BigDecimal.ONE); }
    | ID op='++' { BigDecimal oldVal = getOrCreate($ID.text); varMap.put($ID.text, oldVal.add(BigDecimal.ONE)); $i=oldVal; }
    | ID op='--' { BigDecimal oldVal = getOrCreate($ID.text); varMap.put($ID.text, oldVal.subtract(BigDecimal.ONE)); $i=oldVal; }
    | op='-' e=arithExpr { $i= $e.i.negate(); }
    | <assoc=right> el=arithExpr op='^' er=arithExpr { $i=($el.i.pow($er.i.intValue())); } // note that floating point values cannot be passed to pow... just like bc
    | el=arithExpr op=('*'|'/') er=arithExpr { $i=($op.text.equals("*")) ? $el.i.multiply($er.i) : $el.i.divide($er.i); }
    | el=arithExpr op=('+'|'-') er=arithExpr { $i=($op.text.equals("+")) ? $el.i.add($er.i) : $el.i.subtract($er.i); }
//    | op='!' e=arithExpr { if ($e.i==0) { $i=1; } else { $i=0; } }
//    | el=arithExpr op='&&' er=arithExpr { if ($el.i!=0&&$er.i!=0) { $i=1; } else { $i=0; } }
//    | el=arithExpr op='||' er=arithExpr { if ($el.i!=0||$er.i!=0) { $i=1; } else { $i=0; } }
    | varDef { $i = $varDef.i;}
    | FLOAT { $i = new BigDecimal($FLOAT.text); }
    | ID { $i=getOrCreate($ID.text); }
//    | func { $i = $func.i ;}
    | '(' e=arithExpr ')' { $i = $e.i; }
    ;

/* 
func returns [double i]:
    'read()' { $i = input.nextDouble(); }
    | ID '(' arg=arithExpr ')' { $i=fnMap.get($ID.text).execute($arg.i); }
    ;
*/

/* Lexer rules */
C_COMMENT: [/][*](.|[\r\n])*?[*][/] -> skip;
POUND_COMMENT: [#](.)*?EXPR_END -> skip;
/*
Comments is defined with the lazy definition so that
we match the nearest * /
*/

VAR: 'var';  // keyword
ID: [_A-Za-z]+;
FLOAT: [0-9]*[.]?[0-9]+;
EXPR_END: [(\r?\n);|EOF];
WS : [ \t]+ -> skip ;
