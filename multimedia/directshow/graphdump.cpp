#include <dshow.h>

void DumpGraph(const IGraphBuilder *pGraph)
{
	using std::cout;
	using std::endl;
	IBaseFilter *pFlt = NULL;
	IEnumFilters *pEnumFlt = NULL;
	FILTER_INFO fltInfo;

	IEnumPins *pEnumPin = NULL;
	IPin *pPin = NULL;
	PIN_INFO pinInfo;
	HRESULT hr, hr2;
	TCHAR ptr[32] = {0};
	hr = const_cast<IGraphBuilder*>(pGraph)->EnumFilters(&pEnumFlt);
	if(FAILED(hr))
		return;
	do
	{
		hr = pEnumFlt->Next(1, &pFlt, NULL);
		if(S_OK != hr || NULL == pFlt)
			break;

		pFlt->QueryFilterInfo(&fltInfo);
		OutputDebugString(TEXT("\t"));
		wsprintf(ptr, TEXT("0x%08X "), pFlt);
		OutputDebugString(ptr);
		OutputDebugString(fltInfo.achName);
		OutputDebugString(TEXT("\n"));
		cout << fltInfo.achName << endl;
		
		hr2 = pFlt->EnumPins(&pEnumPin);
		do
		{
			hr2 = pEnumPin->Next(1, &pPin, NULL);
			if(S_OK != hr2 || NULL == pPin)
				break;

			pPin->QueryPinInfo(&pinInfo);
			OutputDebugString(TEXT("\t\t"));
			wsprintf(ptr, TEXT("0x%08X "), pPin);
			OutputDebugString(ptr);
			if(PINDIR_INPUT == pinInfo.dir)
				OutputDebugString(TEXT("[In ]\t"));
			else
				OutputDebugString(TEXT("[Out]\t"));
			OutputDebugString(pinInfo.achName);
			OutputDebugString(TEXT("\n"));

			pPin->Release();
		} while(S_OK == hr2);
		pEnumPin->Release();

		pFlt->Release();
		pFlt = NULL;
	} while(S_OK == hr);
	pEnumFlt->Release();
}
