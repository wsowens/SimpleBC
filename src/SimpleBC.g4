grammar SimpleBC;
/* This grammar was created to follow the specification provided here:
   https://www.gnu.org/software/bc/manual/html_mono/bc.html */
@header {
import java.util.ArrayList;
import java.math.BigDecimal;
import java.util.HashMap;
}


@members {
abstract class ASTNode {
    ArrayList<ASTNode> children = new ArrayList<ASTNode>();

    public String toString(){
        String str = "( " + this.getClass().getSimpleName();
        for (ASTNode child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }

    public abstract Object visit(Env env);
}

abstract class ExprNode extends ASTNode {
    public abstract BigDecimal visit(Env env);
}

abstract class UnaryExpr extends ExprNode {
    ExprNode child;
    public UnaryExpr( ExprNode child) {
        this.child = child;
        this.children.add(child);
    }
}

abstract class BinaryExpr extends ExprNode {
    ExprNode left;
    ExprNode right;
    public BinaryExpr(ExprNode left, ExprNode right) {
        this.left = left;
        this.right = right;
        this.children.add(left);
        this.children.add(right);
    }
    
}

class PreInc extends ExprNode {
    String id;
    public PreInc(String id) {
        this.id = id;
    }

    public BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PreDec extends ExprNode {
    String id;
    public PreDec(String id) {
        this.id = id;
    }

    public BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PostInc extends ExprNode {
    String id;
    public PostInc(String id) {
        this.id = id;
    }

    public BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PostDec extends ExprNode {
    String id;
    public PostDec(String id) {
        this.id = id;
    }

    public BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class Negate extends UnaryExpr {
    public Negate(ExprNode child) {
        super(child);
    }
    public BigDecimal visit(Env env)
    {
        return this.child.visit(env).negate();
    }
}

class Power extends BinaryExpr {
    public Power(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        return this.left.visit(env).pow(this.right.visit(env).intValue());
    }
}

class Mul extends BinaryExpr {
    public Mul(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        return this.left.visit(env).multiply(this.right.visit(env));
    }
}

class Div extends BinaryExpr {
    public Div(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        //TODO: change this later
        return this.left.visit(env).divide(this.right.visit(env), 20, BigDecimal.ROUND_DOWN);
    }
}

class Add extends BinaryExpr {
    public Add(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        return this.left.visit(env).add(this.right.visit(env));
    }
}

class Sub extends BinaryExpr {
    public Sub(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        return this.left.visit(env).subtract(this.right.visit(env));
    }
}

class Assign extends ExprNode {
    String id;
    ExprNode child;
    public Assign(String id, ExprNode child) {
        this.id = id;
        this.child = child;
    }

    public BigDecimal visit(Env env) {
        BigDecimal value = child.visit(env);
        env.locals().put(id, value);
        return value;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + " " + this.child + ")";
    }
}

class Lt extends BinaryExpr {
    public Lt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == -1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Le extends BinaryExpr {
    public Le(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == -1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Gt extends BinaryExpr {
    public Gt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == 1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Ge extends BinaryExpr {
    public Ge(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == 1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Eq extends BinaryExpr {
    public Eq(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if ( result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class NotEq extends BinaryExpr {
    public NotEq(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if ( result != 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}


class Not extends UnaryExpr {
    public Not(ExprNode child) {
        super(child);
    }
        
    public BigDecimal visit(Env env) {
        if (this.child.visit(env).equals(BigDecimal.ZERO)) { 
            return BigDecimal.ONE; 
        } 
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class And extends BinaryExpr {
    public And(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        if (!(left.visit(env).equals(BigDecimal.ZERO)) && !(right.visit(env).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Or extends BinaryExpr {
    public Or(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(Env env)
    {
        if (!(left.visit(env).equals(BigDecimal.ZERO)) || !(right.visit(env).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Var extends ExprNode {
    String id;

    public Var(String id) {
        
        this.id = id;
    }

    public BigDecimal visit(Env env) {
        if (env.locals().containsKey(id)) {
            return env.locals().get(id);
        }
        else {
            env.locals().put(id, BigDecimal.ZERO);
            return BigDecimal.ZERO;
        }
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }

}


class Const extends ExprNode {
    BigDecimal value;

    public Const(BigDecimal value) {
        
        this.value = value;
    }

    public BigDecimal visit(Env env) {
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value.toString() + ")";
    }
}


class Func extends ExprNode {
    String func;
    ArrayList<ExprNode> args = new ArrayList<ExprNode>();
    public Func(String name, ArrayList args) {
        func = name;
        this.args = args;
        this.children = args;
    }

    public BigDecimal visit(Env env) {
        //TODO: actually handle getting the function
        return BigDecimal.ZERO;
    }
    
}

class Env {
    ArrayList<HashMap<String, BigDecimal>> stack = new ArrayList<HashMap<String, BigDecimal>>();
    //change this to list to contain FuncNodes
    HashMap<String, ExprNode> functions = new HashMap<String, ExprNode>();
    public Env() {
        this.push();
    }

    HashMap<String, BigDecimal> locals() {
        return stack.get(stack.size()-1);
    }

    HashMap<String, BigDecimal> globals() {
        return stack.get(0);
    }

    public void pop() {
        stack.remove(stack.size()-1);
    }

    public void push() {
        stack.add(new HashMap<String, BigDecimal>());
    }

    boolean hasID(String id) {
        if (locals().containsKey(id)) {
            return true;
        }
        return globals().containsKey(id);
    }

    BigDecimal getID(String id) {
        if (locals().containsKey(id)) {
            return locals().get(id);
        }
        if (globals().containsKey(id)) {
            return globals().get(id);
        }
        locals().put(id, BigDecimal.ZERO);
        return BigDecimal.ZERO;
    }

    void putID(String id, BigDecimal value)
    {
        //check if it's a global variable first
        if (globals().containsKey(id)) {
           globals().put(id, value);
        }
        else {
            locals().put(id, value);
        }
    }
}
    
}

file: 
     (statement | define) ( ( SEMI | ENDLINE | SEMI ENDLINE ) (statement|define))*
    ;

define:
    'define' name=ID '(' (args+=ID (',' args+=ID)*)? ')' ENDLINE? '{' states+=statement ( ( SEMI | ENDLINE | SEMI ENDLINE ) states+=statement)* '}' ; 

statement:
      e=expr { if (!($e.en instanceof Assign)) { System.out.println($e.en.visit(new Env())); } }
    | STRING  /* strings should be printed literally */
    | 'print' printable ((SEMI | COMMA) printable)* /* refine this to allow for spacew */
    | '{' statement ( ( SEMI | ENDLINE | SEMI ENDLINE ) statement)* '}' 
    | 'if' '(' cond=expr ')' stat1=statement ('else' stat2=statement)?
    | 'while' '(' cond=expr ')' ENDLINE? stat=statement
    | 'for' '(' pre=expr SEMI cond=expr SEMI post=expr ')'
    | 'break'
    | 'continue'
    | 'halt' /* end bc upon execution */
    | 'return' ( value=expr )? /* if no value is provided, return 0 */
    ;

printable:
    | expr
    | STRING
    ;

testExpr:
     e=expr {  Env env = new Env(); System.out.println($e.en); System.out.println($e.en.visit(env));}
    ;

expr returns [ExprNode en]:
      op='++' ID { $en = new PreInc($ID.text); }
    | op='--' ID { $en = new PreDec($ID.text); }
    | ID op='++' { $en = new PostInc($ID.text); }
    | ID op='--' { $en = new PostDec($ID.text); }
    | op='-' e=expr { $en = new Negate($e.en); }
    | <assoc=right> el=expr op='^' er=expr { $en = new Power($el.en, $er.en); }
    | el=expr op=('*'|'/') er=expr { $en=($op.text.equals("*")) ? new Mul($el.en, $er.en) : new Div($el.en, $er.en); }
    | el=expr op=('+'|'-') er=expr { $en=($op.text.equals("+")) ? new Add($el.en, $er.en) : new Sub($el.en, $er.en); }
    | '(' e=expr ')' { $en = $e.en; } 
    /* assignment */
    | ID '=' e=expr { $en = new Assign($ID.text, $e.en); }
    /* relational expressions */
    | el=expr '<'  er=expr { $en = new Lt($el.en, $er.en); }
    | el=expr '<=' er=expr { $en = new Le($el.en, $er.en); }
    | el=expr '>'  er=expr { $en = new Gt($el.en, $er.en); }
    | el=expr '>=' er=expr { $en = new Ge($el.en, $er.en); }
    | el=expr '==' er=expr { $en = new Eq($el.en, $er.en); }
    | el=expr '!=' er=expr { $en = new NotEq($el.en, $er.en); }
    /* boolean expressions */
    | op='!' e=expr { $en = new Not($e.en); }
    | el=expr op='&&' er=expr { $en = new And($el.en, $er.en); }
    | el=expr op='||' er=expr { $en = new Or($el.en, $er.en); }
    | FLOAT { $en = new Const(new BigDecimal($FLOAT.text)); }
    | ID    { $en = new Var($ID.text); }
    | ID '(' { ArrayList<ExprNode> args = new ArrayList<ExprNode>(); $en = new Func($ID.text, args);} (arg=expr  {args.add($arg.en); } (',' next=expr {args.add($next.en); System.out.println("Test!");})*)?  // not working
    ;

func returns [ExprNode en] :
    //'read()'  { $i = new BigDecimal(input.nextLine().trim()); }  worry about this later }
    
    ;

/* Lexer rules */
ID: [_A-Za-z]+;
FLOAT: [0-9]*[.]?[0-9]+; 
STRING: ["].*?["]; /* lazy definition of string */
WS : [ \t]+ -> skip ;
C_COMMENT: [/][*](.)*?[*][/] -> skip;
P_COMMENT: '#' (.)*? ENDLINE -> skip;
ENDLINE: '\r'?'\n';
SEMI: ';';
COMMA: ',';