# YACC-Parser
```
Parses the following grammar:  
<s> ::= <prog>  
<prog> ::= <tstart> <tfinish> | 
           <tstart> <DL> <SL> <tfinish> |
           <tstart> <DL> <tfinish>
<DL> ::= <DL> <D> |
         <D>
<D> ::= <tid> <Dtail>  
<Dtail> ::= , <tid> <Dtail> |
            : <type> ;   
<type> ::= <tint> | 
           <tfloat> |
           <tbool>   
<SL> ::= <SL> <S> |
         <S>   
<S> ::= <tprint> <tstrlit> ; |
        <tprint> <tid> ; |
        <tprintln> ; |
        <tid> <tassign> <expr> ; |
        <error> ;   
<expr> ::= <expr> + <term> |
           <expr> - <term> |
           <term>   
<term> ::= <term> * <factor> |
           <term> / <factor> |
           <factor>   
<factor> ::= <tid> |
             <tintlit> |
             <tfloatlit> |
             <ttrue> |
             <tfalse>  
