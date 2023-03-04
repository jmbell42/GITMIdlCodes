from matplotlib.colors import LinearSegmentedColormap
from numpy import nan, inf
cm_data = [[0.968627, 0.988235, 0.960784],
[0.964706, 0.988235, 0.956863],
[0.964706, 0.988235, 0.956863],
[0.960784, 0.984314, 0.952941],
[0.960784, 0.984314, 0.94902],
[0.956863, 0.984314, 0.94902],
[0.956863, 0.984314, 0.945098],
[0.952941, 0.980392, 0.941176],
[0.94902, 0.980392, 0.941176],
[0.94902, 0.980392, 0.937255],
[0.945098, 0.980392, 0.933333],
[0.945098, 0.980392, 0.933333],
[0.941176, 0.976471, 0.929412],
[0.937255, 0.976471, 0.92549],
[0.937255, 0.976471, 0.92549],
[0.933333, 0.976471, 0.921569],
[0.933333, 0.972549, 0.917647],
[0.929412, 0.972549, 0.913725],
[0.929412, 0.972549, 0.913725],
[0.92549, 0.972549, 0.909804],
[0.921569, 0.968627, 0.905882],
[0.921569, 0.968627, 0.905882],
[0.917647, 0.968627, 0.901961],
[0.917647, 0.968627, 0.898039],
[0.913725, 0.968627, 0.898039],
[0.909804, 0.964706, 0.894118],
[0.909804, 0.964706, 0.890196],
[0.905882, 0.964706, 0.890196],
[0.905882, 0.964706, 0.886275],
[0.901961, 0.960784, 0.882353],
[0.901961, 0.960784, 0.882353],
[0.898039, 0.960784, 0.878431],
[0.894118, 0.960784, 0.87451],
[0.890196, 0.956863, 0.870588],
[0.886275, 0.956863, 0.866667],
[0.882353, 0.956863, 0.862745],
[0.878431, 0.952941, 0.858824],
[0.87451, 0.952941, 0.854902],
[0.870588, 0.94902, 0.85098],
[0.870588, 0.94902, 0.847059],
[0.866667, 0.94902, 0.843137],
[0.862745, 0.945098, 0.839216],
[0.858824, 0.945098, 0.835294],
[0.854902, 0.945098, 0.831373],
[0.85098, 0.941176, 0.827451],
[0.847059, 0.941176, 0.823529],
[0.843137, 0.937255, 0.819608],
[0.839216, 0.937255, 0.815686],
[0.835294, 0.937255, 0.811765],
[0.831373, 0.933333, 0.807843],
[0.827451, 0.933333, 0.803922],
[0.823529, 0.933333, 0.8],
[0.819608, 0.929412, 0.796078],
[0.815686, 0.929412, 0.792157],
[0.811765, 0.92549, 0.788235],
[0.811765, 0.92549, 0.784314],
[0.807843, 0.92549, 0.780392],
[0.803922, 0.921569, 0.776471],
[0.8, 0.921569, 0.772549],
[0.796078, 0.921569, 0.768627],
[0.792157, 0.917647, 0.764706],
[0.788235, 0.917647, 0.760784],
[0.784314, 0.913725, 0.756863],
[0.780392, 0.913725, 0.752941],
[0.776471, 0.913725, 0.74902],
[0.772549, 0.909804, 0.745098],
[0.764706, 0.909804, 0.741176],
[0.760784, 0.905882, 0.733333],
[0.756863, 0.905882, 0.729412],
[0.752941, 0.901961, 0.72549],
[0.74902, 0.901961, 0.721569],
[0.745098, 0.898039, 0.717647],
[0.737255, 0.898039, 0.713725],
[0.733333, 0.894118, 0.705882],
[0.729412, 0.894118, 0.701961],
[0.72549, 0.890196, 0.698039],
[0.721569, 0.890196, 0.694118],
[0.713725, 0.886275, 0.690196],
[0.709804, 0.886275, 0.686275],
[0.705882, 0.882353, 0.682353],
[0.701961, 0.882353, 0.67451],
[0.698039, 0.878431, 0.670588],
[0.690196, 0.878431, 0.666667],
[0.686275, 0.87451, 0.662745],
[0.682353, 0.87451, 0.658824],
[0.678431, 0.870588, 0.654902],
[0.67451, 0.870588, 0.647059],
[0.670588, 0.866667, 0.643137],
[0.662745, 0.866667, 0.639216],
[0.658824, 0.862745, 0.635294],
[0.654902, 0.862745, 0.631373],
[0.65098, 0.858824, 0.627451],
[0.647059, 0.858824, 0.619608],
[0.639216, 0.854902, 0.615686],
[0.635294, 0.854902, 0.611765],
[0.631373, 0.85098, 0.607843],
[0.627451, 0.847059, 0.603922],
[0.619608, 0.847059, 0.6],
[0.615686, 0.843137, 0.596078],
[0.607843, 0.839216, 0.588235],
[0.603922, 0.839216, 0.584314],
[0.6, 0.835294, 0.580392],
[0.592157, 0.831373, 0.576471],
[0.588235, 0.831373, 0.572549],
[0.580392, 0.827451, 0.568627],
[0.576471, 0.823529, 0.560784],
[0.572549, 0.823529, 0.556863],
[0.564706, 0.819608, 0.552941],
[0.560784, 0.815686, 0.54902],
[0.552941, 0.815686, 0.545098],
[0.54902, 0.811765, 0.541176],
[0.545098, 0.811765, 0.537255],
[0.537255, 0.807843, 0.529412],
[0.533333, 0.803922, 0.52549],
[0.52549, 0.803922, 0.521569],
[0.521569, 0.8, 0.517647],
[0.513725, 0.796078, 0.513725],
[0.509804, 0.796078, 0.509804],
[0.505882, 0.792157, 0.501961],
[0.498039, 0.788235, 0.498039],
[0.494118, 0.788235, 0.494118],
[0.486275, 0.784314, 0.490196],
[0.482353, 0.780392, 0.486275],
[0.478431, 0.780392, 0.482353],
[0.470588, 0.776471, 0.47451],
[0.466667, 0.772549, 0.470588],
[0.458824, 0.772549, 0.466667],
[0.454902, 0.768627, 0.462745],
[0.447059, 0.764706, 0.458824],
[0.443137, 0.760784, 0.454902],
[0.435294, 0.760784, 0.454902],
[0.431373, 0.756863, 0.45098],
[0.423529, 0.752941, 0.447059],
[0.415686, 0.74902, 0.443137],
[0.411765, 0.74902, 0.443137],
[0.403922, 0.745098, 0.439216],
[0.4, 0.741176, 0.435294],
[0.392157, 0.737255, 0.431373],
[0.384314, 0.733333, 0.427451],
[0.380392, 0.733333, 0.427451],
[0.372549, 0.729412, 0.423529],
[0.368627, 0.72549, 0.419608],
[0.360784, 0.721569, 0.415686],
[0.356863, 0.721569, 0.415686],
[0.34902, 0.717647, 0.411765],
[0.341176, 0.713725, 0.407843],
[0.337255, 0.709804, 0.403922],
[0.329412, 0.705882, 0.4],
[0.32549, 0.705882, 0.4],
[0.317647, 0.701961, 0.396078],
[0.309804, 0.698039, 0.392157],
[0.305882, 0.694118, 0.388235],
[0.298039, 0.690196, 0.384314],
[0.294118, 0.690196, 0.384314],
[0.286275, 0.686275, 0.380392],
[0.278431, 0.682353, 0.376471],
[0.27451, 0.678431, 0.372549],
[0.266667, 0.678431, 0.372549],
[0.262745, 0.67451, 0.368627],
[0.254902, 0.670588, 0.364706],
[0.25098, 0.666667, 0.360784],
[0.247059, 0.662745, 0.360784],
[0.243137, 0.658824, 0.356863],
[0.239216, 0.654902, 0.352941],
[0.235294, 0.65098, 0.34902],
[0.231373, 0.647059, 0.34902],
[0.227451, 0.643137, 0.345098],
[0.227451, 0.639216, 0.341176],
[0.223529, 0.635294, 0.337255],
[0.219608, 0.631373, 0.337255],
[0.215686, 0.627451, 0.333333],
[0.211765, 0.623529, 0.329412],
[0.207843, 0.619608, 0.32549],
[0.203922, 0.615686, 0.32549],
[0.2, 0.611765, 0.321569],
[0.196078, 0.607843, 0.317647],
[0.192157, 0.603922, 0.313725],
[0.188235, 0.6, 0.313725],
[0.184314, 0.596078, 0.309804],
[0.180392, 0.592157, 0.305882],
[0.176471, 0.588235, 0.301961],
[0.172549, 0.584314, 0.301961],
[0.168627, 0.580392, 0.298039],
[0.168627, 0.576471, 0.294118],
[0.164706, 0.572549, 0.290196],
[0.160784, 0.568627, 0.290196],
[0.156863, 0.564706, 0.286275],
[0.152941, 0.560784, 0.282353],
[0.14902, 0.556863, 0.278431],
[0.145098, 0.552941, 0.278431],
[0.141176, 0.54902, 0.27451],
[0.137255, 0.545098, 0.270588],
[0.133333, 0.541176, 0.266667],
[0.129412, 0.537255, 0.262745],
[0.12549, 0.533333, 0.262745],
[0.121569, 0.529412, 0.258824],
[0.117647, 0.52549, 0.254902],
[0.109804, 0.521569, 0.25098],
[0.105882, 0.517647, 0.25098],
[0.101961, 0.517647, 0.247059],
[0.0980392, 0.513725, 0.243137],
[0.0941176, 0.509804, 0.239216],
[0.0901961, 0.505882, 0.235294],
[0.0862745, 0.501961, 0.235294],
[0.0823529, 0.498039, 0.231373],
[0.0784314, 0.494118, 0.227451],
[0.0745098, 0.490196, 0.223529],
[0.0705882, 0.486275, 0.223529],
[0.0627451, 0.482353, 0.219608],
[0.0588235, 0.478431, 0.215686],
[0.054902, 0.47451, 0.211765],
[0.0509804, 0.470588, 0.207843],
[0.0470588, 0.466667, 0.207843],
[0.0431373, 0.462745, 0.203922],
[0.0392157, 0.458824, 0.2],
[0.0352941, 0.458824, 0.196078],
[0.0313725, 0.454902, 0.192157],
[0.027451, 0.45098, 0.192157],
[0.0196078, 0.447059, 0.188235],
[0.0156863, 0.443137, 0.184314],
[0.0117647, 0.439216, 0.180392],
[0.00784314, 0.435294, 0.180392],
[0.00392157, 0.431373, 0.176471],
[0., 0.427451, 0.172549],
[0., 0.423529, 0.168627],
[0., 0.415686, 0.168627],
[0., 0.411765, 0.164706],
[0., 0.407843, 0.164706],
[0., 0.403922, 0.160784],
[0., 0.396078, 0.160784],
[0., 0.392157, 0.156863],
[0., 0.388235, 0.156863],
[0., 0.380392, 0.152941],
[0., 0.376471, 0.152941],
[0., 0.372549, 0.14902],
[0., 0.368627, 0.14902],
[0., 0.360784, 0.145098],
[0., 0.356863, 0.145098],
[0., 0.352941, 0.141176],
[0., 0.34902, 0.141176],
[0., 0.341176, 0.137255],
[0., 0.337255, 0.133333],
[0., 0.333333, 0.133333],
[0., 0.32549, 0.129412],
[0., 0.321569, 0.129412],
[0., 0.317647, 0.12549],
[0., 0.313725, 0.12549],
[0., 0.305882, 0.121569],
[0., 0.301961, 0.121569],
[0., 0.298039, 0.117647],
[0., 0.290196, 0.117647],
[0., 0.286275, 0.113725],
[0., 0.282353, 0.113725],
[0., 0.278431, 0.109804],
[0., 0.270588, 0.109804],
[0., 0.266667, 0.105882]]

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
