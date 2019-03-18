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
        String str = "(" + this.getClass().getSimpleName();
        for (ASTNode child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }

    public abstract Object visit(Env env);
}

interface Printable {
    public Object visit(Env env, boolean doPrint);
}

class Root extends ASTNode{
    public void add(ASTNode an) {
        //TODO: remove this later
        if (an != null) {
            System.out.println("Adding: " + an);
            children.add(an);
        }
        System.out.println(children.size());
    }

    public Object visit(Env env) {

        for (ASTNode child : children) {
            child.visit(env);
        }
        return null;
    }
}

class Expr extends ASTNode implements Printable {
    ExprNode child;
    
    Expr(ExprNode n) {
        child = n;
        children.add(n);
    }

    public Object visit(Env env) {
        BigDecimal result = child.visit(env);
        System.out.println(result);
        return result;

    }

    public Object visit(Env env, boolean doPrint) {
        BigDecimal result = child.visit(env);
        if (doPrint)
            System.out.println(result);
        return result;
    }

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

class Str extends ASTNode implements Printable {
    String value;
    public Str(String value) {
        this.value = value;
    }

    public String visit(Env env) {
        return this.visit(env, true);
    }

    public String visit(Env env, boolean doPrint) {
        if (doPrint) {
            System.out.print(this.value);
        }
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value + ")";
    }
}

class Print extends ASTNode {
    ArrayList<Printable> children = new ArrayList<Printable>();

    public void add(Printable child) {
        children.add(child);
    }

    public Object visit(Env env) {
        for (Printable child : children)
        {
            System.out.print(child.visit(env, false));
        }
        return null;
    }

    public String toString(){
        String str = "(" + this.getClass().getSimpleName();
        for (Printable child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }
}

class Block extends ASTNode {

    public void add(ASTNode child) {
        this.children.add(child);
    }

    public Object visit(Env env) {
        for (ASTNode child : children)
        {
            child.visit(env);
        }
        return null;
    }
}

class IfElse extends ASTNode { 
    ExprNode cond;
    ASTNode ifNode;
    ASTNode elseNode;

    IfElse(ExprNode cond, ASTNode ifNode) {
        this.cond = cond;
        this.ifNode = ifNode;
        this.elseNode = null;
    }

    public Object visit(Env env) {
        BigDecimal result = cond.visit(env);
        if (result.equals(BigDecimal.ZERO))
        {
            if (elseNode != null) {
               return this.elseNode.visit(env);
            }
            //TODO return something sensible here?
            return BigDecimal.ZERO;
        }
        else {
            return this.ifNode.visit(env);
        }
    }

    void addElse(ASTNode elseNode) {
        this.elseNode = elseNode;
        this.children.add(elseNode);
    }
}

class While extends ASTNode {
    ExprNode cond;
    ASTNode body;
    While(ExprNode cond, ASTNode body) {
        this.cond = cond;
        this.body = body;
        this.children.add(cond);
        this.children.add(body);
    }

    public Object visit(Env env) {
        while ( !(cond.visit(env).equals(BigDecimal.ZERO)) ) {
            body.visit(env);
        }
        return null;
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
    { Root root = new Root(); }
     (st=statement { root.add($st.an); }| define) ( ( SEMI | ENDLINE | SEMI ENDLINE ) ( nxt=statement { root.add($nxt.an);} | define | EOF ))* EOF?
    { root.visit(new Env()); System.err.println(root); }
    ;

define:
    'define' name=ID '(' (args+=ID (',' args+=ID)*)? ')' ENDLINE? '{' states+=statement ( ( SEMI | ENDLINE | SEMI ENDLINE ) states+=statement)* '}' ; 

statement returns [ASTNode an]:
      e=expr   { $an= new Expr($e.en);} 
    | s=STRING { $an= new Str($s.text);}
    | 'print' { Print p = new Print(); $an = p; } fp=printable { p.add($fp.pn); } ((SEMI | COMMA)                   np=printable {p.add($np.pn);})*
    | '{'     { Block b = new Block(); $an = b; } fs=statement { b.add($fs.an); } ((SEMI | ENDLINE | SEMI ENDLINE ) ns=statement {b.add($ns.an);})* '}' 
    | 'if' '(' con=expr ')'  ifs=statement {IfElse ie = new IfElse($con.en, $ifs.an); $an = ie;} ('else' elses=statement { ie.addElse($elses.an);} )? {}
    | 'while' '(' cond=expr ')' ENDLINE? stat=statement { $an = new While($cond.en, $stat.an); }
    | 'for' '(' pre=expr SEMI cond=expr SEMI post=expr ')'
    | 'break'
    | 'continue'
    | 'halt' /* end bc upon execution */
    | 'return' ( value=expr )? /* if no value is provided, return 0 */
    ;

printable returns [Printable pn]:
    | e=expr { $pn = new Expr($e.en); }
    | s=STRING { $pn = new Str($s.text); }
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