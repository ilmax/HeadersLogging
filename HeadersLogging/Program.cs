using System.Text;
using Microsoft.AspNetCore.HttpLogging;

var builder = WebApplication.CreateBuilder(args);
var port = builder.Configuration.GetValue("PORT", 8080);
builder.WebHost.ConfigureKestrel((_, serverOptions) =>
{
    serverOptions.ListenAnyIP(port);
});
builder.Services.AddHttpLogging(logging =>
{
    logging.LoggingFields = HttpLoggingFields.All;
    logging.CombineLogs = true;
});

var app = builder.Build();
app.UseHttpLogging();

app.Run(async (ctx) =>
{
    var sb = new StringBuilder();
    sb.AppendLine("Request info:");
    sb.AppendLine("-----------------");
    sb.AppendLine($"Url:            {ctx.Request.Path}{ctx.Request.QueryString}");
    sb.AppendLine($"Method:         {ctx.Request.Method}");
    sb.AppendLine($"Protocol:       {ctx.Request.Protocol}");
    sb.AppendLine($"Host:           {ctx.Request.Host}");
    sb.AppendLine($"Client IP:      {ctx.Connection.RemoteIpAddress}");
    sb.AppendLine();
    sb.AppendLine("Request Headers:");
    sb.AppendLine("-----------------");
    
    var maxHeaderLength = ctx.Request.Headers.Max(h => h.Key.Length) + 3;
    foreach (var requestHeader in ctx.Request.Headers)
    {
        sb.AppendLine($"{requestHeader.Key.PadRight(maxHeaderLength, ' ')}{requestHeader.Value}");
    }
    
    await ctx.Response.WriteAsync(sb.ToString());
});

app.Run();
