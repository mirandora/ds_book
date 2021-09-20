class Worker{
  //席位置
  int s_x;
  int s_y;
  
  int x;
  int y;
  
  //会話状態。(会話中なら徐々に減衰)
  int talk_status;
  int next_talk_status;
  
  //自分かどうか
  int me;
  
  //友情（仲の良い人が2人くらいいる）
  int friend_ship;
  int friend_idx;
  
  //カウントタイマー（一定時間後ランダムに移動）
  int counttimer;
  
  Worker(){
    talk_status = int(random(255));    
    me = 0;
    friend_ship = 0;
    friend_idx = -1;
    counttimer = 0;
  }
    
  void talk(){    
    int neighbor_talk = 0;
    int side_talk = 0;
    int front_talk = 0;
    
    int neighbor_fs = 0;
    
    float talk_probability;
    
    //自分を中心に席が存在するかチェックしてもし存在するなら追加
        
    for (int i = s_x-1; i<=s_x+1; i++){
      for (int j = s_y-1; j<=s_y+1; j++){
        //println(i,j,s_x,s_y,table_c,table_r);
        if ((i >= 0) && (i < table_c) && (j >= 0) && (j < table_r)){
          neighbor_talk += workers[i + j*table_c].talk_status; 
          neighbor_fs += workers[i + j*table_c].friend_ship;           
          
          //もし正面なら
          if (j == s_y){
            front_talk += workers[i + j*table_c].talk_status; 
          }
          //もし隣なら
          if (abs(s_x - i) == 1){
            side_talk += workers[i + j*table_c].talk_status; 
          }
        }
      }
    }
    
    next_talk_status = talk_status;
    
    //ルール1：周りの会話量が閾値以下になると会話終了。
    //ルール2：周りの会話量が閾値以上になると会話終了（会話に入れない）
    if ((neighbor_talk < 50) || (neighbor_talk > 500)){
      if (next_talk_status > 50){
        next_talk_status -= 50;
      }
    }    
    
    //ルール3：目の前の人、あるいは隣の人が話していたら一定確率で会話継続
    if ((side_talk > 50) || (front_talk > 50)){
      talk_probability = random(1);
      
      if ((next_talk_status < 50) && (talk_probability < 0.2)){
        next_talk_status += (side_talk + front_talk) * 0.15;
      }
    }
    
    //自分ルール
    if (me == 1){
      //ルール1：初期状態は親しい人の数で決める。
      if((frame_ct == 0) && (next_talk_status < 100)){
        next_talk_status += neighbor_fs * 25;      
      }
      if (neighbor_fs >= 1){
        //ルール2：親しい人との会話は盛り上がりに応じてネタが枯渇。        
        if(next_talk_status > neighbor_talk*0.03*neighbor_fs){
          next_talk_status -= neighbor_talk*0.03*neighbor_fs;
        }
        //ルール3：親しい人がいると一定確率で話す。
        talk_probability = random(1);
        if ((talk_probability < 0.05*neighbor_fs) && (next_talk_status < 30)){
          next_talk_status += next_talk_status * 1.5;
        }      
      }
      //ルール4：周囲に一人も親しい人がいないと話さない。
      if(neighbor_fs == 0){
        next_talk_status = 0;      
      }
      
    }  
    
  }
  
  void update(){
    talk_status = next_talk_status;    
    
    //前のtalk_statusから更新
    if (talk_status > 5){
      talk_status -=int(random(1)*5);
    }    
    
    //周りの状態に関係なく、突発的に一定確率で話す。
    float talk_probability = random(1);
    if (me != 1){
      if ((talk_probability < 0.2) && (talk_status < 50)){
        talk_status += 80;
      }
    }
    
    if (me == 1){
      tmp_me_talk_status = talk_status;
    }
    else{
      tmp_ave_talk_status += talk_status;    
    }    
    
    //print(talk_status + ",");
    
  }
  
  void sitdown(int c, int r){
    s_x = c;
    s_y = r;
    
    x = c * seat_width;
    y = r * seat_width;
  }
  
  void display(){        
    fill(255-talk_status);
    
    if (me==1){ //自分
      stroke(255,0,0);
      strokeWeight(3);
    }else if(friend_ship == 1){ //仲の良い同僚
      stroke(0,0,255);
      strokeWeight(3);
    }else{ //それ以外
      stroke(0);
      strokeWeight(2);      
    }
    
    rect(x+width/2-((seat_width * table_c)/2),y+height/2-((seat_width * table_r)/2),seat_width,seat_width);    
  }    
}

Worker[] workers;
//飲み会の席
int table_c = 10;
int table_r = 10;
int seat_width = 30;
int frame_ct = 0;

int friend_num = 6;

int tmp_me_talk_status = 0;
float tmp_ave_talk_status = 0;

int[] seat_array = new int[friend_num+1];


int array_check(int[] tmp_array, int tmp_num){
  int contains_idx = -1;
  
  for (int i = 0; i< tmp_array.length;i++){
    if (tmp_array[i] == tmp_num){
      contains_idx = i;
    }
  }
  
  return contains_idx;
}

int get_fs_ct(int tmp_c, int tmp_r){
  int fs_sum = 0;
  
  for (int i=-1;i<2;i++){
    if (((tmp_c +i)>=0) && ((tmp_c +i)<=9)){
      for(int j=-1;j<2;j++){
        if (((tmp_r +j)>=0) && ((tmp_r +j)<=9)){
          fs_sum += workers[(tmp_c + i) + (tmp_r + j)*table_c].friend_ship;          
        }
      }
    }  
  }
  
  return fs_sum;
}

void setup(){
  size(640,320);  
  background(255);
  
  //16人の同僚
  workers = new Worker[table_c * table_r];
  //自分の席を決める。      
  int tmp_me_c = int(random(10));
  int tmp_me_r = int(random(10));      
  
  seat_array[0] = tmp_me_c + tmp_me_r*table_c;

  //仲の良い同僚の席を決める。
  for (int i=0;i<friend_num;i++){
    int tmp_fr_c;
    int tmp_fr_r;
    
    while(true){
      tmp_fr_c = int(random(10));
      tmp_fr_r = int(random(10));      
      
      if(array_check(seat_array,tmp_fr_c+tmp_fr_r*table_c) == -1){
        //println(tmp_fr_c,tmp_fr_r);
        seat_array[i+1] = tmp_fr_c + tmp_fr_r*table_c;        
        break;        
      }
    }            
  }
    
  for(int c=0;c<table_c;c++){
    for(int r=0;r<table_r;r++){
      workers[c + r*table_c] = new Worker();
      
      if ((c == tmp_me_c) && (r == tmp_me_r)){
        workers[c + r * table_c].me = 1;            
      }      
      else if (array_check(seat_array,c+r*table_c) != -1){
        workers[c + r*table_c].friend_ship = 1;          
        workers[c + r*table_c].friend_idx = array_check(seat_array,c+r*table_c);          
      }
      
      //workerのカウントダウンタイマーセット
      workers[c + r*table_c].counttimer = int(random(100))+50;
      
      workers[c + r*table_c].sitdown(c,r);
      workers[c + r*table_c].display();      
    }
  }  
}

void draw(){
  tmp_me_talk_status = 0;
  tmp_ave_talk_status = 0;  
  
  for(int i=0;i<workers.length;i++){
    workers[i].talk();    
    workers[i].display();    
  }
  for(int i=0;i<workers.length;i++){
    workers[i].update();    
    
    if (workers[i].counttimer == 0){
      workers[i].counttimer = int(random(100))+50;
      int tmp_move_c = int(random(10));
      int tmp_move_r = int(random(10));      
      
      workers[tmp_move_c + tmp_move_r * table_c].sitdown(workers[i].s_x, workers[i].s_y);
      workers[i].sitdown(tmp_move_c, tmp_move_r);      
      
      //seat_arrayを更新
      if (workers[i].friend_ship == 1){
        seat_array[workers[i].friend_idx] = workers[i].s_x +  workers[i].s_y*table_c;
      }            
    }    
    
    if(workers[i].counttimer > 0){
      workers[i].counttimer--;
    }
        
    /*
    //もし自分の周囲の親しい人の数が0なら友人の少し近く(-1〜+1)に移動
    if (workers[i].me == 1){
      int tmp_fs = get_fs_ct(workers[i].s_x, workers[i].s_y);
      if (tmp_fs == 0){
        int tmp_me_x = -1;
        int tmp_me_y = -1;
        for(int j=1;j < seat_array.length;j++){
          //seat_arrayの座標を取り出して、
          int tmp_x = seat_array[j]%table_c;
          int tmp_y = (seat_array[j] - seat_array[j]%table_c)/table_c;
          
          //その-1〜+1が存在するならスワップ
          if (tmp_x -1 >= 0){
            tmp_me_x = tmp_x -1;  
          }
          else if (tmp_x + 1 <= table_c){
            tmp_me_x = tmp_x + 1;
          }
          
          if (tmp_y - 1 >= 0){
            tmp_me_y = tmp_y -1;
          }
          else if (tmp_y + 1 <= table_r){
            tmp_me_y = tmp_y + 1;
          }
          
          if ((tmp_me_x != -1) && (tmp_me_y != -1)){
            break;           
          }
        }        
        if ((tmp_me_x != -1) && (tmp_me_y != -1)){
          workers[tmp_me_x + tmp_me_y*table_c].sitdown(workers[i].s_x,workers[i].s_y);
          workers[i].sitdown(tmp_me_x,tmp_me_y);                                        
        }
      }
    }  
    */    
  }  
  
  tmp_ave_talk_status = tmp_ave_talk_status/100;
  println(tmp_me_talk_status, tmp_ave_talk_status);  
  
  frame_ct++;  
}
