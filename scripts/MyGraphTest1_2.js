var samples_size;
var samples=[];

//document.getElementById("buttonu8263").on("click", function(){
//                  document.getElementById("led_status").load("cgi-bin/ledoff.sh");
//});
// 
//document.getElementById("buttonu8260").on("click", function(){
//                  document.getElementById("led_status").load("cgi-bin/ledon.sh");
//});
// 
//document.getElementById("buttonu8431").on("click", function(){
//                  document.getElementById("led_status").load("cgi-bin/ledblink.sh");
//});
// 
//document.getElementById("buttonu8266").on("click", function(){
//                  document.getElementById("led_status").load("cgi-bin/povstart.sh");
//});
// 
//document.getElementById("buttonu8269").on("click", function(){
//                  document.getElementById("led_status").load("cgi-bin/povstop.sh");
//});
// 
//document.getElementById("buttonu8022").on("click", function(){
//     document.getElementById('fft_data').bind("DOMSubtreeModified",function(){
//          draw();
//     });
//     document.getElementById("fft_data").load("cgi-bin/fft_sine.sh");
//});
// 
//document.getElementById("buttonu8272").on("click", function(){
//     document.getElementById('fft_data').bind("DOMSubtreeModified",function(){
//          draw();
//     });
//     document.getElementById("fft_data").load("cgi-bin/fft_square.sh");
//});
// 
//document.getElementById("buttonu8275").on("click", function(){
//     document.getElementById('fft_data').bind("DOMSubtreeModified",function(){
//          draw();
//     });
//     document.getElementById("fft_data").load("cgi-bin/fft_triangle.sh");
//});


function draw() {
        var canvas = document.getElementById("canvas");
        //if (null==canvas || !canvas.getContext) return;
        if(canvas == null) 
        {
          canvas = document.createElement('canvas');
          canvas.id     = "canvas";
          canvas.width  = 522;
          canvas.height = 340;
          canvas.style.zIndex   = 8;
          canvas.style.position = "absolute";
          //canvas.style.border   = "1px solid";
          div = document.getElementById("u9762"); 
          div.appendChild(canvas)
        }


        var fft_data = document.getElementById("fft_data");


        var MarginLeft = 0.05*canvas.width;
        var MarginRight = 0.05*canvas.width;
        var MarginTop = 0.1*canvas.height;
        var MarginBottom = 0.3*canvas.height;	

        var axes={}, ctx=canvas.getContext("2d");
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        axes.xWidth = canvas.width-(MarginLeft+MarginRight); 
        axes.yHeight = canvas.height-(MarginTop+MarginBottom);	
        axes.x0 = MarginLeft;  // x0 pixels from left to x=0
        axes.y0 = MarginTop; // y0 pixels from top to y=0
        axes.doNegativeX = false;	
        //axes.scale = axes.y0;

        //var w = canvas.width;
        //var h = canvas.height; 	

        // fill samples
        samples = fft_data.innerHTML.split(",");
        for(var i=0; i<samples.length; i++) { samples[i] = parseInt(samples[i], 10); } 

        var cpu_time  = samples[samples.length-2];
        var fpga_time = samples[samples.length-1];
        samples.splice(samples.length-2,2);
        samples_size = samples.length;

        if(samples_size < 255)
        {
          document.getElementById("u8308-4").innerHTML = cpu_time;
          document.getElementById("u8309-4").innerHTML = fpga_time;
          document.getElementById("u8310-4").innerHTML = cpu_time - fpga_time;
          return;
        }
        else if(samples_size < 4095 && samples_size >= 0)
        {
          document.getElementById("u8302-4").innerHTML = cpu_time;
          document.getElementById("u8303-4").innerHTML = fpga_time;
          document.getElementById("u8304-4").innerHTML = cpu_time - fpga_time;
        }
        else if(samples_size < 1024*1024-1)
        {
          document.getElementById("u8305-4").innerHTML = cpu_time;
          document.getElementById("u8306-4").innerHTML = fpga_time;
          document.getElementById("u8307-4").innerHTML = cpu_time - fpga_time;
        }

        var SamplesToPlot={};
        SamplesToPlot.content = samples;
        //var max_of_array = Math.max.apply(Math, array);
        SamplesToPlot.maxvalue = Math.max.apply(Math, samples.slice(1));
        SamplesToPlot.minvalue = Math.min.apply(Math, samples.slice(1));
        //SamplesToPlot.maxvalue = 130000;
        //SamplesToPlot.minvalue = 0;
        //SamplesToPlot.range = SamplesToPlot.maxvalue - SamplesToPlot.minvalue;

        // Calculating the position of the X-Axis on the Y-Axis
        if (SamplesToPlot.maxvalue < 0) {
                SamplesToPlot.maxvalue = 0;
                axes.XaxisPos = axes.y0;  
                SamplesToPlot.range = 0 - SamplesToPlot.minvalue;
        }
        else if (SamplesToPlot.minvalue > 0) {
                SamplesToPlot.minvalue = 0;
                axes.XaxisPos = axes.y0+axes.yHeight;
                SamplesToPlot.range = SamplesToPlot.maxvalue;
        }
        else	{
                SamplesToPlot.range = SamplesToPlot.maxvalue - SamplesToPlot.minvalue;			
                //SamplesToPlot.range = SamplesToPlot.maxvalue - ;			
                axes.XaxisPos = axes.y0 + ((SamplesToPlot.maxvalue/SamplesToPlot.range)*axes.yHeight);		 
        }

        showAxes(ctx,axes);
        //funGraph(ctx,axes,fun1,"rgb(11,153,11)",1); 
        funGraph(ctx,axes,SamplesToPlot,"rgb(66,44,255)",2);
}

function funGraph (ctx,axes,SamplesToPlot,color,thick) {
        var xx, yy, dx, x0=axes.x0, y0=axes.y0, scale=axes.scale;
        //var iMax = Math.round((ctx.canvas.width)/dx);
        //var iMin = axes.doNegativeX ? Math.round(-x0/dx) : 0;
        ctx.beginPath();
        ctx.lineWidth = thick;
        ctx.strokeStyle = color;

        dx = axes.xWidth / (samples_size-1);

        for (var i=0;i<samples_size;i++) {
                xx = x0+dx*i; 
                yy = samples[i];
                if (i==0) ctx.moveTo(xx,axes.y0+(((SamplesToPlot.maxvalue-yy)/SamplesToPlot.range)*axes.yHeight));
                //first sample = -10...range= 140, minvalue=-120.... maxvalue=20    (20--10)/140
                else         ctx.lineTo(xx,axes.y0+(((SamplesToPlot.maxvalue-yy)/SamplesToPlot.range)*axes.yHeight));
        }
        ctx.stroke();
        ctx.fillStyle = "black";
        ctx.font = "bold 13px sans-serif";
        ctx.fillText("Number of Samples = ", 20,y0+axes.yHeight+40);
        ctx.fillText(String(samples_size), 20+200,y0+axes.yHeight+40);
        //ctx.fillText("X-axis = SAMPLE#", axes.x0+axes.xWidth+5,y0);	
        ctx.fillText("Sample Maximum Value = ", 20,y0+axes.yHeight+60);
        ctx.fillText(String(SamplesToPlot.maxvalue), 20+200,y0+axes.yHeight+60);	
        //ctx.fillText(String(Math.max.apply(Math, samples)), 20+200,y0+axes.yHeight+60);	
        ctx.fillText("Sample Minimum Value = ", 20,y0+axes.yHeight+80);	
        ctx.fillText(String(SamplesToPlot.minvalue), 20+200,y0+axes.yHeight+80);	
        //ctx.fillText(String(Math.min.apply(Math, samples)), 20+200,y0+axes.yHeight+80);	

}


function showAxes(ctx,axes) {
        var x0=axes.x0, 	w=ctx.canvas.width;
        var y0=axes.XaxisPos, 	h=ctx.canvas.height;

        //var xmin = axes.doNegativeX ? 0 : x0;
        ctx.beginPath();
        ctx.strokeStyle = "rgb(0,0,0)"; 
        ctx.moveTo(x0,y0); ctx.lineTo(x0+axes.xWidth,y0);  // X axis
        ctx.moveTo(x0,axes.y0);    ctx.lineTo(x0,axes.y0+axes.yHeight);  // Y axis
        ctx.strokeStyle = "rgb(40,40,40)"; 
        ctx.moveTo(x0,y0-axes.yHeight/4); ctx.lineTo(x0+axes.xWidth, y0-axes.yHeight/4);  // X axis
        ctx.moveTo(x0,y0-axes.yHeight/2); ctx.lineTo(x0+axes.xWidth, y0-axes.yHeight/2);  // X axis
        ctx.moveTo(x0,y0-3*axes.yHeight/4); ctx.lineTo(x0+axes.xWidth, y0-3*axes.yHeight/4);  // X axis
        ctx.stroke();
        ctx.fillStyle = "black";
        ctx.font = "bold 13px sans-serif";
        // Now use green paint
        //ctx.fill();
        // And fill area under curve
        ctx.fillText("Y-axis = Frequency Amplitude", w/2 - 100,20);
        ctx.fillText("X-axis = Sample #", x0,axes.y0+axes.yHeight+20);
}
