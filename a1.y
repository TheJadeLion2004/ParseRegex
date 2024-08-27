  %{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <iostream>
    #include <vector>
    #include <algorithm>
    #include <map>
    #include <set>
    #include <string>
    #include <queue>
    using namespace std;

    void yyerror(char *);
    int yylex(void);
    extern char *yytext;

    struct node {
      string nodetype;
      int nodeid;
      int isnullable;
      set<int> firstpos;
      set<int> lastpos;
    };

    vector<node> globalstore;
    map<int, set<int>> followpos;
    set<int> dfastart;
    int globalctr = 0;

    void printFollowpos(const map<int, set<int>>& followpos) {
      for (const auto& [key, value] : followpos) {
          cout << "Node " << key << " -> {";
          for (auto it = value.begin(); it != value.end(); ++it) {
              if (it != value.begin()) {
                  cout << ", ";
              }
              cout << *it;
          }
          cout << "}" << endl;
      }
  }
    

    int final_node;
    queue<int> unmarked;


    struct states{
      int state_id;
      set<int> associated_parse_states;
      int is_final;
    };

    struct edges{
      int from_state;
      int to_state;
      string transchar;
    };
    
    int globalstatectr = 0;
    vector<states> statelist;
    vector<edges> edgelist;

    void printStatelist() {
    for (const auto& state : statelist) {
        cout << "State ID: " << state.state_id << endl;
        cout << "Associated Parse States: {";
        for (auto it = state.associated_parse_states.begin(); it != state.associated_parse_states.end(); ++it) {
            if (it != state.associated_parse_states.begin()) {
                cout << ", ";
            }
            cout << *it;
        }
        cout << "}" << endl;
        cout << "Is Final: " << (state.is_final ? "Yes" : "No") << endl;
        cout << "--------------------------" << endl;
    }
}
  %}

  %union {
    struct node* nodeval;
    int intval;
  }

  %type<nodeval> or_expr cat_expr terminal
  %type<intval> var

  %%

  program: or_expr { 
        dfastart = $1->firstpos;  
        if ($1->isnullable == 1) {
          dfastart.insert(globalctr);
        }
        
        set<int> t = {globalctr};
        
        for (const int &number : $1->lastpos) {
          set<int> joinedset;
          set_union(followpos[number].begin(), followpos[number].end(), t.begin(), t.end(), inserter(joinedset, joinedset.begin()));
          followpos[number] = joinedset;
        }
        final_node = globalctr;
        states temp_state;
        temp_state.state_id = globalstatectr;
        globalstatectr++;
        temp_state.associated_parse_states = dfastart;
        if (dfastart.find(final_node)!= dfastart.end()){
          temp_state.is_final = 1;
        }
        else{
          temp_state.is_final = 0;
        }
        statelist.push_back(temp_state); 
        unmarked.push(0);
      }
  ;

  or_expr: cat_expr '|' or_expr {
        node *temp = new node;
        temp->nodetype = "|";
        temp->nodeid = globalctr++;
        temp->isnullable = ($1->isnullable) * ($3->isnullable);
        set_union($1->firstpos.begin(), $1->firstpos.end(), $3->firstpos.begin(), $3->firstpos.end(), inserter(temp->firstpos, temp->firstpos.begin()));
        set_union($1->lastpos.begin(), $1->lastpos.end(), $3->lastpos.begin(), $3->lastpos.end(), inserter(temp->lastpos, temp->lastpos.begin()));
        globalstore.push_back(*temp);
        $$ = temp;
      }
    | cat_expr { $$ = $1; }
  ;

  cat_expr: cat_expr terminal {
        node *temp = new node;
        temp->nodetype = ".";
        temp->nodeid = globalctr++;
        temp->isnullable = ($1->isnullable) * ($2->isnullable);
        if ($1->isnullable == 1) {
          set_union($1->firstpos.begin(), $1->firstpos.end(), $2->firstpos.begin(), $2->firstpos.end(), inserter(temp->firstpos, temp->firstpos.begin()));
        } else {
          temp->firstpos = $1->firstpos;
        }
        if ($2->isnullable == 1) {
          set_union($1->lastpos.begin(), $1->lastpos.end(), $2->lastpos.begin(), $2->lastpos.end(), inserter(temp->lastpos, temp->lastpos.begin()));
        } else {
          temp->lastpos = $2->lastpos;
        }
        for (const int &number : $1->lastpos) {
          set<int> joinedset;
          set_union(followpos[number].begin(), followpos[number].end(), $2->firstpos.begin(), $2->firstpos.end(), inserter(joinedset, joinedset.begin()));
          followpos[number] = joinedset;
        }
        globalstore.push_back(*temp);
        $$ = temp;
      }
    | terminal { $$ = $1; }
  ;
  terminal: '(' or_expr ')' {
          $$ = $2;
          }
    | var {
			node *temp = new node;
			if ($1 == 1) temp->nodetype = "a"; else temp->nodetype = "b";
			temp->nodeid = globalctr++;
			temp->isnullable = 0;
			temp->firstpos = {temp->nodeid};
			temp->lastpos = {temp->nodeid};
			followpos[temp->nodeid] = {};
			globalstore.push_back(*temp);
		    	$$ = temp;
    }
    | terminal '*' {
			node *temp = new node;
			temp->nodetype = "*";
			temp->nodeid = globalctr++;
			temp->firstpos = $1->firstpos;
			temp->isnullable = 1;
			temp->lastpos = $1->lastpos;
			for (const int &number : $1->lastpos) {
				set<int> joinedset;
				set_union(followpos[number].begin(), followpos[number].end(), temp->firstpos.begin(), temp->firstpos.end(), inserter(joinedset, joinedset.begin()));
				followpos[number] = joinedset;
			}
			globalstore.push_back(*temp);
			$$ = temp;
		}
  ;

  var: 'a' {$$ =  1;}| 'b' {$$ = 2;}
  ;



  %%

  void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
  }

  int main(void) {
    yyparse();
    printFollowpos(followpos);  
    while (!unmarked.empty()){
      int tid = unmarked.front();
      set<int> temp = statelist[tid].associated_parse_states;
      unmarked.pop();
      set<int> alist;
      set<int> blist;
      for (auto i: temp){
        if (globalstore[i].nodetype == "a"){
          alist.insert(followpos[i].begin(), followpos[i].end());
        }
        else if (globalstore[i].nodetype == "b"){
          blist.insert(followpos[i].begin(), followpos[i].end());
        }
      }
      int astate = -1;
      int bstate = -1;
      for(int i = 0; i < statelist.size(); i++){
        if (alist == statelist[i].associated_parse_states){
          astate = i;
        }
        if (blist == statelist[i].associated_parse_states){
          bstate = i;
        }
      }
      if (astate == -1 && !alist.empty()){
        int temp_state_id = globalstatectr;
        astate = temp_state_id;
        globalstatectr++;
        states temp_state;
        temp_state.state_id = temp_state_id;
        temp_state.associated_parse_states = alist;
        if (alist.find(final_node)!= alist.end()){
          temp_state.is_final = 1;
        }
        else{
          temp_state.is_final = 0;
        }
        statelist.push_back(temp_state); 
        unmarked.push(temp_state_id);
      } 
      if (bstate == -1 && !blist.empty()){
        int temp_state_id = globalstatectr;
        bstate = temp_state_id;
        globalstatectr++;
        states temp_state;
        temp_state.state_id = temp_state_id;
        temp_state.associated_parse_states = blist;
        if (blist.find(final_node)!= blist.end()){
          temp_state.is_final = 1;
        }
        else{
          temp_state.is_final = 0;
        }
        statelist.push_back(temp_state); 
        unmarked.push(temp_state_id);
      }
      if (astate != -1){
        edges tempedgea;
        tempedgea.from_state = tid;
        tempedgea.to_state = astate;      
        tempedgea.transchar = "a";
        edgelist.push_back(tempedgea);
      }
      if (bstate != -1){
        edges tempedgeb;
        tempedgeb.from_state = tid;
        tempedgeb.to_state = bstate;
        tempedgeb.transchar = "b";
        edgelist.push_back(tempedgeb);
      }
    }
    printStatelist();   
    cout << "digraph DFA {" << endl << "  rankdir = TB;" << endl     ;
    for (int i = 0; i <   statelist.size(); i++){
      cout << "   q" << i;   
      if (statelist[i].is_final == 1){
        cout << " [shape=doublecircle];" <<endl;
      }
      else{
        cout << " [shape=circle];" <<endl;
      } 
    }
    for (int i = 0; i < edgelist.size(); i++){
      cout << " q" << edgelist[i].from_state << " -> q" << edgelist[i].to_state << " [label=\"" << edgelist[i].transchar << "\"];"<<endl;
    }   
    cout << "}" << endl;
    
    return 0;
  }
