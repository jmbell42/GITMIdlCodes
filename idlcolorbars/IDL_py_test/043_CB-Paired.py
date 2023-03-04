from matplotlib.colors import LinearSegmentedColormap
from numpy import nan, inf
cm_data = [[0.65098, 0.807843, 0.890196],
[0.627451, 0.792157, 0.882353],
[0.603922, 0.780392, 0.87451],
[0.580392, 0.764706, 0.866667],
[0.560784, 0.74902, 0.858824],
[0.537255, 0.733333, 0.85098],
[0.513725, 0.721569, 0.843137],
[0.490196, 0.705882, 0.835294],
[0.466667, 0.690196, 0.827451],
[0.443137, 0.67451, 0.819608],
[0.419608, 0.662745, 0.811765],
[0.396078, 0.647059, 0.803922],
[0.376471, 0.631373, 0.792157],
[0.352941, 0.615686, 0.784314],
[0.329412, 0.603922, 0.776471],
[0.305882, 0.588235, 0.768627],
[0.282353, 0.572549, 0.760784],
[0.258824, 0.556863, 0.752941],
[0.235294, 0.545098, 0.745098],
[0.211765, 0.529412, 0.737255],
[0.192157, 0.513725, 0.729412],
[0.168627, 0.498039, 0.721569],
[0.145098, 0.486275, 0.713725],
[0.121569, 0.470588, 0.705882],
[0.145098, 0.486275, 0.698039],
[0.172549, 0.505882, 0.690196],
[0.196078, 0.521569, 0.686275],
[0.223529, 0.541176, 0.678431],
[0.247059, 0.556863, 0.670588],
[0.270588, 0.576471, 0.662745],
[0.298039, 0.592157, 0.654902],
[0.321569, 0.611765, 0.647059],
[0.34902, 0.627451, 0.643137],
[0.372549, 0.647059, 0.635294],
[0.396078, 0.662745, 0.627451],
[0.423529, 0.682353, 0.619608],
[0.447059, 0.698039, 0.611765],
[0.470588, 0.717647, 0.603922],
[0.498039, 0.733333, 0.6],
[0.521569, 0.752941, 0.592157],
[0.54902, 0.768627, 0.584314],
[0.572549, 0.788235, 0.576471],
[0.596078, 0.803922, 0.568627],
[0.623529, 0.823529, 0.560784],
[0.647059, 0.839216, 0.556863],
[0.67451, 0.858824, 0.54902],
[0.698039, 0.87451, 0.541176],
[0.67451, 0.862745, 0.52549],
[0.654902, 0.854902, 0.509804],
[0.631373, 0.843137, 0.494118],
[0.611765, 0.831373, 0.478431],
[0.588235, 0.819608, 0.462745],
[0.568627, 0.811765, 0.443137],
[0.545098, 0.8, 0.427451],
[0.52549, 0.788235, 0.411765],
[0.501961, 0.776471, 0.396078],
[0.482353, 0.768627, 0.380392],
[0.458824, 0.756863, 0.364706],
[0.439216, 0.745098, 0.34902],
[0.415686, 0.733333, 0.333333],
[0.396078, 0.72549, 0.317647],
[0.372549, 0.713725, 0.301961],
[0.352941, 0.701961, 0.286275],
[0.329412, 0.690196, 0.270588],
[0.309804, 0.682353, 0.25098],
[0.286275, 0.670588, 0.235294],
[0.266667, 0.658824, 0.219608],
[0.243137, 0.647059, 0.203922],
[0.223529, 0.639216, 0.188235],
[0.2, 0.627451, 0.172549],
[0.235294, 0.627451, 0.192157],
[0.266667, 0.623529, 0.207843],
[0.301961, 0.623529, 0.227451],
[0.337255, 0.623529, 0.247059],
[0.368627, 0.623529, 0.266667],
[0.403922, 0.619608, 0.282353],
[0.439216, 0.619608, 0.301961],
[0.47451, 0.619608, 0.321569],
[0.505882, 0.619608, 0.341176],
[0.541176, 0.615686, 0.356863],
[0.576471, 0.615686, 0.376471],
[0.607843, 0.615686, 0.396078],
[0.643137, 0.615686, 0.415686],
[0.678431, 0.611765, 0.431373],
[0.709804, 0.611765, 0.45098],
[0.745098, 0.611765, 0.470588],
[0.780392, 0.611765, 0.490196],
[0.815686, 0.607843, 0.505882],
[0.847059, 0.607843, 0.52549],
[0.882353, 0.607843, 0.545098],
[0.917647, 0.607843, 0.564706],
[0.94902, 0.603922, 0.580392],
[0.984314, 0.603922, 0.6],
[0.980392, 0.580392, 0.580392],
[0.976471, 0.560784, 0.556863],
[0.972549, 0.537255, 0.537255],
[0.968627, 0.517647, 0.513725],
[0.964706, 0.494118, 0.494118],
[0.960784, 0.47451, 0.470588],
[0.956863, 0.45098, 0.45098],
[0.952941, 0.427451, 0.431373],
[0.94902, 0.407843, 0.407843],
[0.945098, 0.384314, 0.388235],
[0.941176, 0.364706, 0.364706],
[0.933333, 0.341176, 0.345098],
[0.929412, 0.321569, 0.321569],
[0.92549, 0.298039, 0.301961],
[0.921569, 0.278431, 0.278431],
[0.917647, 0.254902, 0.258824],
[0.913725, 0.231373, 0.239216],
[0.909804, 0.211765, 0.215686],
[0.905882, 0.188235, 0.196078],
[0.901961, 0.168627, 0.172549],
[0.898039, 0.145098, 0.152941],
[0.894118, 0.12549, 0.129412],
[0.890196, 0.101961, 0.109804],
[0.894118, 0.129412, 0.121569],
[0.898039, 0.156863, 0.137255],
[0.901961, 0.184314, 0.14902],
[0.905882, 0.211765, 0.164706],
[0.909804, 0.235294, 0.176471],
[0.917647, 0.262745, 0.192157],
[0.921569, 0.290196, 0.203922],
[0.92549, 0.317647, 0.219608],
[0.929412, 0.345098, 0.231373],
[0.933333, 0.372549, 0.247059],
[0.937255, 0.4, 0.258824],
[0.941176, 0.427451, 0.27451],
[0.945098, 0.45098, 0.286275],
[0.94902, 0.478431, 0.298039],
[0.952941, 0.505882, 0.313725],
[0.956863, 0.533333, 0.32549],
[0.960784, 0.560784, 0.341176],
[0.968627, 0.588235, 0.352941],
[0.972549, 0.615686, 0.368627],
[0.976471, 0.643137, 0.380392],
[0.980392, 0.666667, 0.396078],
[0.984314, 0.694118, 0.407843],
[0.988235, 0.721569, 0.423529],
[0.992157, 0.74902, 0.435294],
[0.992157, 0.737255, 0.415686],
[0.992157, 0.72549, 0.396078],
[0.992157, 0.717647, 0.380392],
[0.992157, 0.705882, 0.360784],
[0.992157, 0.694118, 0.341176],
[0.996078, 0.682353, 0.321569],
[0.996078, 0.67451, 0.301961],
[0.996078, 0.662745, 0.282353],
[0.996078, 0.65098, 0.266667],
[0.996078, 0.639216, 0.247059],
[0.996078, 0.627451, 0.227451],
[0.996078, 0.619608, 0.207843],
[0.996078, 0.607843, 0.188235],
[0.996078, 0.596078, 0.168627],
[0.996078, 0.584314, 0.152941],
[0.996078, 0.572549, 0.133333],
[0.996078, 0.564706, 0.113725],
[1., 0.552941, 0.0941176],
[1., 0.541176, 0.0745098],
[1., 0.529412, 0.054902],
[1., 0.521569, 0.0392157],
[1., 0.509804, 0.0196078],
[1., 0.498039, 0.],
[0.992157, 0.505882, 0.0352941],
[0.980392, 0.513725, 0.0745098],
[0.972549, 0.52549, 0.109804],
[0.964706, 0.533333, 0.145098],
[0.952941, 0.541176, 0.184314],
[0.945098, 0.54902, 0.219608],
[0.937255, 0.560784, 0.254902],
[0.929412, 0.568627, 0.290196],
[0.917647, 0.576471, 0.329412],
[0.909804, 0.584314, 0.364706],
[0.901961, 0.592157, 0.4],
[0.890196, 0.603922, 0.439216],
[0.882353, 0.611765, 0.47451],
[0.87451, 0.619608, 0.509804],
[0.862745, 0.627451, 0.54902],
[0.854902, 0.635294, 0.584314],
[0.847059, 0.647059, 0.619608],
[0.839216, 0.654902, 0.654902],
[0.827451, 0.662745, 0.694118],
[0.819608, 0.670588, 0.729412],
[0.811765, 0.682353, 0.764706],
[0.8, 0.690196, 0.803922],
[0.792157, 0.698039, 0.839216],
[0.776471, 0.678431, 0.827451],
[0.760784, 0.658824, 0.819608],
[0.741176, 0.639216, 0.807843],
[0.72549, 0.619608, 0.8],
[0.709804, 0.6, 0.788235],
[0.694118, 0.576471, 0.776471],
[0.678431, 0.556863, 0.768627],
[0.662745, 0.537255, 0.756863],
[0.643137, 0.517647, 0.74902],
[0.627451, 0.498039, 0.737255],
[0.611765, 0.478431, 0.72549],
[0.596078, 0.458824, 0.717647],
[0.580392, 0.439216, 0.705882],
[0.564706, 0.419608, 0.694118],
[0.545098, 0.4, 0.686275],
[0.529412, 0.380392, 0.67451],
[0.513725, 0.360784, 0.666667],
[0.498039, 0.337255, 0.654902],
[0.482353, 0.317647, 0.643137],
[0.466667, 0.298039, 0.635294],
[0.447059, 0.278431, 0.623529],
[0.431373, 0.258824, 0.615686],
[0.415686, 0.239216, 0.603922],
[0.439216, 0.270588, 0.603922],
[0.466667, 0.305882, 0.603922],
[0.490196, 0.337255, 0.603922],
[0.517647, 0.372549, 0.603922],
[0.541176, 0.403922, 0.603922],
[0.568627, 0.439216, 0.603922],
[0.592157, 0.470588, 0.603922],
[0.619608, 0.501961, 0.603922],
[0.643137, 0.537255, 0.603922],
[0.670588, 0.568627, 0.603922],
[0.694118, 0.603922, 0.603922],
[0.721569, 0.635294, 0.6],
[0.745098, 0.670588, 0.6],
[0.772549, 0.701961, 0.6],
[0.796078, 0.737255, 0.6],
[0.823529, 0.768627, 0.6],
[0.847059, 0.8, 0.6],
[0.87451, 0.835294, 0.6],
[0.898039, 0.866667, 0.6],
[0.92549, 0.901961, 0.6],
[0.94902, 0.933333, 0.6],
[0.976471, 0.968627, 0.6],
[1., 1., 0.6],
[0.988235, 0.972549, 0.580392],
[0.976471, 0.945098, 0.564706],
[0.960784, 0.917647, 0.545098],
[0.94902, 0.890196, 0.52549],
[0.937255, 0.862745, 0.505882],
[0.92549, 0.839216, 0.490196],
[0.909804, 0.811765, 0.470588],
[0.898039, 0.784314, 0.45098],
[0.886275, 0.756863, 0.435294],
[0.87451, 0.729412, 0.415686],
[0.858824, 0.701961, 0.396078],
[0.847059, 0.67451, 0.380392],
[0.835294, 0.647059, 0.360784],
[0.823529, 0.619608, 0.341176],
[0.807843, 0.592157, 0.321569],
[0.796078, 0.564706, 0.305882],
[0.784314, 0.537255, 0.286275],
[0.772549, 0.513725, 0.266667],
[0.756863, 0.486275, 0.25098],
[0.745098, 0.458824, 0.231373],
[0.733333, 0.431373, 0.211765],
[0.721569, 0.403922, 0.192157],
[0.705882, 0.376471, 0.176471],
[0.694118, 0.34902, 0.156863]]

test_cm = LinearSegmentedColormap.from_list(__file__, cm_data)


if __name__ == "__main__":
    import matplotlib.pyplot as plt
    import numpy as np

    try:
        from pycam02ucs.cm.viscm import viscm
        viscm(test_cm)
    except ImportError:
        print("pycam02ucs not found, falling back on simple display")
        plt.imshow(np.linspace(0, 100, 256)[None, :], aspect='auto',
                   cmap=test_cm)
    plt.show()
