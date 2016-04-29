class Volet{
    int ouvert = 0,
        x,
        y;
    boolean manuel = false;
 
    Volet(int x, int y){
        this.x = x;
        this.y = y;
    }

    void update(int timer, boolean manuel){
        this.manuel = manuel;
        if(timer > 0 && !this.manuel && ouvert <=100){
            if(ouvert < 100)
                ouvert++;
        }else if(ouvert > 0)
            ouvert--;
        stroke(2);
        fill(color(80, 80, 80));
        rect(x, y-8, 100-ouvert+8, 16);
        rect(x+100+ouvert+8, y-8, 100-ouvert+8, 16);
    }
}