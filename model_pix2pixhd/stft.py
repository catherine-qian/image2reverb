import torch
import torchvision.transforms
import torchaudio


M_PI = 3.14159265358979323846264338


class STFT(torch.nn.Module):
    def __init__(self, window_size=1024, hop_length=256, window="hann"):
        super().__init__()
        self._w_size = window_size
        self._h_length = hop_length
        self._w = {"hann": torch.hann_window}[window](self._w_size) # Window table
        self._n = torchvision.transforms.Normalize((0.5, 0.5), (0.5, 0.5))

    def transform(self, audio):
        s = torch.stft(audio, self._w_size, self._h_length, window=self._w, return_complex=True).squeeze()[:-1,:] # Get STFT and trim Nyquist bin
        return torch.abs(s.unsqueeze(0)) # Magnitude

    def inverse(self, spec):
        s = torch.cat((spec, torch.zeros(1, spec.shape[1]).cuda()))
        random_phase = torch.Tensor(s.shape).uniform_(-M_PI, M_PI)
        s = torch.stack((s, random_phase), -1)
        audio = torch.istft(s, self._w_size, self._h_length, window=self._w.cuda()) # Audio output
        return audio/torch.abs(audio).max()
