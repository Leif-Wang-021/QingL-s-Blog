function varargout = WMMSE_SISO(varargin)
%WMMSE_SISO  Compatibility wrapper for WMMSE_MIMO.

if nargout == 0
	WMMSE_MIMO(varargin{:});
	return;
end

[varargout{1:nargout}] = WMMSE_MIMO(varargin{:});
end