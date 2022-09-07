import ctypes
from ctypes import c_void_p, c_int, c_char_p, c_bool, POINTER, byref

# load libraries
libx11 = ctypes.CDLL('libX11.so.6')
print('loaded libx11:', libx11)
libXcomposite = ctypes.CDLL('libXcomposite.so.1')
print('loaded libXcomposite:', libXcomposite)

# load symbols
XInitThreads = libx11['XInitThreads']
XInitThreads.argtypes = ()
XInitThreads.restype = c_int
XOpenDisplay = libx11['XOpenDisplay']
XOpenDisplay.argtypes = (c_char_p,)
XOpenDisplay.restype = c_void_p

XCompositeQueryExtension = libXcomposite['XCompositeQueryExtension']
XCompositeQueryExtension.argtypes = (c_void_p, POINTER(c_int), POINTER(c_int))
XCompositeQueryExtension.restype = c_bool
XCompositeQueryVersion = libXcomposite['XCompositeQueryVersion']
XCompositeQueryVersion.argtypes = (c_void_p, POINTER(c_int), POINTER(c_int))
XCompositeQueryVersion.restype = c_int
# we don't call these, but ensure they exist
XCompositeVersion = libXcomposite['XCompositeVersion']
XCompositeRedirectWindow = libXcomposite['XCompositeRedirectWindow']
XCompositeRedirectSubwindows = libXcomposite['XCompositeRedirectSubwindows']
XCompositeUnredirectWindow = libXcomposite['XCompositeUnredirectWindow']
XCompositeUnredirectSubwindows = libXcomposite['XCompositeUnredirectSubwindows']
XCompositeCreateRegionFromBorderClip = libXcomposite['XCompositeCreateRegionFromBorderClip']
XCompositeNameWindowPixmap = libXcomposite['XCompositeNameWindowPixmap']

print('loaded symbols')

# open display
if XInitThreads() == 0:
    print('warning: XInitThreads() failed')
x_display = XOpenDisplay(None)
print('display:', x_display)

# query XComposite extension
xcomp_major_version = c_int(0)
xcomp_minor_version = c_int(0)
version_ret = XCompositeQueryVersion(
    x_display, byref(xcomp_major_version), byref(xcomp_minor_version))
print(f'XCompositeQueryVersion: return = {version_ret}, '
    f'major = {xcomp_major_version}, minor = {xcomp_minor_version}')
if version_ret == 0:
    print('warning: XCompositeQueryVersion: unsupported version')

xcomp_event_base = c_int(0)
xcomp_error_base = c_int(0)
success = XCompositeQueryExtension(
    x_display, byref(xcomp_event_base), byref(xcomp_error_base))
print(f'XCompositeQueryExtension: success = {success}, '
    f'event_base = {xcomp_event_base}, error_base = {xcomp_error_base}')
if not success:
    print('warning: XCompositeQueryExtension: extension not present')
