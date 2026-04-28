#NoEnv
#SingleInstance force
codepage = 65001
password := "default_password"
url := "https://textdb.dev/api/data/028e9d18-dddb-41e4-b28a-b4a6f39dfe30"
; 远程剪贴板
+f9::
  clipboard := ""
  Send ^c
  ClipWait
  if DllCall("IsClipboardFormatAvailable", "uint", 15) { ; CF_HDROP = 15, 文件
    files := []
    if DllCall("OpenClipboard", "uint", 0) {
      hDrop := DllCall("GetClipboardData", "uint", 15)
      fileCount := DllCall("DragQueryFile", "uint", hDrop, "uint", 0xFFFFFFFF, "uint", 0, "uint", 0)
      Loop %fileCount% {
        VarSetCapacity(filePath, 260*2, 0)
        DllCall("DragQueryFile", "uint", hDrop, "uint", A_Index-1, "str", filePath, "uint", 260)
        FileRead, fileContent, *c %filePath%
        encoded := base64Encode(fileContent)
        files.Push({name: SubStr(filePath, InStr(filePath, "\", , 0)+1), path: filePath, content: encoded})
      }
      DllCall("CloseClipboard")
    }
    data := JSON.stringify({type: "files", files: files})
  } else {
    data := clipboard
  }
  encrypted := crypt(data, password, true) ; 加密
  data := encrypted ? encrypted : data
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  whr.Open("POST", url, true)
  whr.SetRequestHeader("Content-Type", "x-www-form-urlencoded;charset=utf-8")
  whr.Send(data)
  whr.WaitForResponse()
  resText := whr.ResponseText
  MsgBox, 2000, , %resText% ; 2秒后关闭
  return
	
+f8::
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  whr.Open("GET", url, true)
  whr.Send()
  whr.WaitForResponse()
  data := whr.ResponseText
  decrypted := crypt(data, password, false) ; 解密
  data := decrypted ? decrypted : data
  parsed := JSON.parse(data)
  if (parsed.type = "files") {
    filePaths := []
    for each, fileData in parsed.files {
      decoded := base64Decode(fileData.content)
      tempFile := A_Temp . "\" . fileData.name
      FileDelete, %tempFile%
      FileAppend, %decoded%, %tempFile%, UTF-8-RAW
      filePaths.Push(tempFile)
    }
    clipboard := filePaths
  } else {
    clipboard := data
  }
  Send ^v
  return

crypt(message, password, isEncrypt := true) {
  tempFile := A_Temp . "\input.txt"
  FileDelete, %tempFile%
  FileAppend, %message%, %tempFile%, UTF-8-RAW
  outFile := A_Temp . "\output.txt"
  FileDelete, %outFile%
  cmd := "cmd /c openssl enc -aes-256-cbc -a -md sha256 -pbkdf2 -iter 1000 -salt -pass pass:" . password . " -in """ . tempFile . """ -out """ . outFile . """" . (isEncrypt ? " -e" : " -d")
  RunWait, %cmd%, , Hide
  FileRead, encrypted, %outFile%, UTF-8-RAW
  FileDelete, %tempFile%
  FileDelete, %outFile%
  return encrypted
}

; Base64 编码函数
base64Encode(ByRef bin, len := "") {
  if (len == "")
    len := StrLen(bin) * (A_IsUnicode ? 2 : 1)
  DllCall("Crypt32.dll\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x40000001, "ptr", 0, "uint*", outLen)
  VarSetCapacity(out, outLen * (A_IsUnicode ? 2 : 1))
  DllCall("Crypt32.dll\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x40000001, "str", out, "uint*", outLen)
  return out
}

; Base64 解码函数
base64Decode(ByRef base64) {
  DllCall("Crypt32.dll\CryptStringToBinary", "ptr", &base64, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", outLen, "ptr", 0, "ptr", 0)
  VarSetCapacity(out, outLen)
  DllCall("Crypt32.dll\CryptStringToBinary", "ptr", &base64, "uint", 0, "uint", 0x1, "ptr", &out, "uint*", outLen, "ptr", 0, "ptr", 0)
  return StrGet(&out, outLen, "UTF-8")
}

; 简单的 JSON 类
class JSON {
  stringify(obj) {
    if IsObject(obj) {
      if obj.MaxIndex() { ; 数组
        str := "["
        for i, v in obj
          str .= (i > 1 ? "," : "") . this.stringify(v)
        return str . "]"
      } else { ; 对象
        str := "{"
        for k, v in obj
          str .= (A_Index > 1 ? "," : "") . """" . k . """:" . this.stringify(v)
        return str . "}"
      }
    } else {
      return """" . StrReplace(obj, """", "\""") . """"
    }
  }
  
  parse(json) {
    ; 简单解析，实际使用需要更复杂的 JSON 解析器
    ; 这里假设格式简单
    return %json%
  }
}