using UnityEngine;
using System;
using System.Collections;
using System.Diagnostics;
using UnityEngine.UI;

public class SSTimer : IDisposable 
{
    private string    m_tag         = string.Empty;
    private Stopwatch m_stopWatch   = null;
    bool m_bRed;
    string m_ReturnName = "";

    static Text text;

    static SSTimer()
    {
        var go = GameObject.Find("Output");
        text = go.GetComponent<Text>();
    }

    public SSTimer()
    {
        
    }

    public SSTimer(string tag, bool isRed = false) 
    {
        m_tag       = tag;
        m_stopWatch = Stopwatch.StartNew();
        m_bRed = isRed;
    }
    public void Stop()
    {
        m_stopWatch.Stop();
    }
    public void Dispose() 
    {
        m_stopWatch.Stop();
        var log = (m_tag + " 加载耗时:  毫秒 == " + m_stopWatch.ElapsedMilliseconds);
        if (m_bRed == false)
        {
            UnityEngine.Debug.Log(log);
        }
        else
        {
            UnityEngine.Debug.LogError(log);
        }

        text.text = text.text + "\n" + log;
    }
}

